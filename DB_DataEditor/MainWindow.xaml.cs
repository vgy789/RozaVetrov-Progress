using DB_DataEditor.DataFiles;
using DB_DataEditor.DataFiles.Models;
using DB_DataEditor.DBEditor;
using DB_DataEditor.Domain;
using DB_DataEditor.PageMain;
using MaterialDesignThemes.Wpf;
using Microsoft.VisualBasic;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace DB_DataEditor
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        
        public MainWindow()
        {
            InitializeComponent();
            NavigationPanel.Visibility = Visibility.Hidden;
            InitializeView();
        }

        /// <summary>
        /// Применине стартовых настроек к MainVindow.
        /// </summary>
        private void InitializeView()
        {
            FrameApp.frameObj = FrameMain;
            FrameMain.Navigate(new PageAutorization(NavigationPanel));
            FrameMain.Visibility = Visibility.Visible;

            TablesListBox.ItemsSource = _tableCollections;
        }

        #region Right Menu

        private void DarkModeToggleButton_Click(object sender, RoutedEventArgs e)
            => ModifyTheme(DarkModeToggleButton.IsChecked == true);

        /// <summary>
        /// Изменение цветовой схемы программы.
        /// </summary>
        /// <param name="isDarkTheme">false - светлая, true - темная схема.</param>
        private static void ModifyTheme(bool isDarkTheme)
        {
            PaletteHelper paletteHelper = new PaletteHelper();
            ITheme theme = paletteHelper.GetTheme();

            theme.SetBaseTheme(isDarkTheme ? Theme.Dark : Theme.Light);

            paletteHelper.SetTheme(theme);
        }

        private void KillProgramButton_Click(object sender, RoutedEventArgs e)
            => this.Close();
        
        private void Button_Click(object sender, RoutedEventArgs e)
            => Link.OpenInBrowser("http://rozavetrovrus.ru/");


        #endregion

        #region Left Menu

        /// <summary>
        /// Приведение значения перечисления в удобочитаемый формат.
        /// </summary>
        /// <remarks>
        /// Для корректной работы необходимо использовать атрибут [Description("Name")] для каждого элемента перечисления.
        /// </remarks>
        /// <param name="enumElement">Элемент перечисления</param>
        /// <returns>Название элемента</returns>
        private static string GetDescription(Enum enumElement)
        {
            Type type = enumElement.GetType();

            MemberInfo[] memInfo = type.GetMember(enumElement.ToString());
            if (memInfo != null && memInfo.Length > 0)
            {
                object[] attrs = memInfo[0].GetCustomAttributes(typeof(DescriptionAttribute), false);
                if (attrs != null && attrs.Length > 0)
                    return ((DescriptionAttribute)attrs[0]).Description;
            }

            return enumElement.ToString();
        }

        /// <summary>
        /// Название страниц и соответствующих таблиц.
        /// </summary>
        private enum TablesName
        {
            [Description("Перевозки")]
            Transportation,
            [Description("Регион")]
            Region,
            [Description("Город")]
            City
        }

        readonly private static Thickness thickness = new Thickness(16, 8, 8, 8);
        readonly private static List<ListBoxItem> _tableCollections = new List<ListBoxItem>
        {
            new ListBoxItem { Content = GetDescription(TablesName.Transportation), Padding = thickness, FontSize = 14, FontWeight = FontWeights.Bold },
            new ListBoxItem { Content = GetDescription(TablesName.Region), Padding = thickness, FontSize = 14 },
            new ListBoxItem { Content = GetDescription(TablesName.City), Padding = thickness, FontSize = 14 }
        };

        private string _seletedItemContext;
        private ListBoxItem _seletedItem;
        private ListBox _itemsHost;

        /// <summary>
        /// Событие указывает на "Кликнутый" Item.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TablesListBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var buff = sender as ListBox;

            if (_seletedItem != null)
                if (_itemsHost != buff)
                    _itemsHost.SelectedItem = null;

            _itemsHost = buff;

            if (e.AddedItems.Count > 0)
            {
                _seletedItem = (ListBoxItem)e.AddedItems[0];

                _seletedItemContext = (string)_seletedItem.Content;
                if (_seletedItemContext == GetDescription(TablesName.City))
                {
                    FrameApp.frameObj.Navigate(new PageCity());
                }
                if (_seletedItemContext == GetDescription(TablesName.Region))
                {
                    FrameApp.frameObj.Navigate(new PageRegion());
                }

            }
        }

        #endregion
    }
}