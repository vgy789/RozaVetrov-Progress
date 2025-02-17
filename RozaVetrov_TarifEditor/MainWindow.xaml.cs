using MaterialDesignThemes.Wpf;
using RozaVetrov_TarifEditor.DataFiles;
using RozaVetrov_TarifEditor.DBEditor.CityEditor;
using RozaVetrov_TarifEditor.DBEditor.SubjectEditor;
using RozaVetrov_TarifEditor.DBEditor.TransportationEditor;
using RozaVetrov_TarifEditor.Domain;
using RozaVetrov_TarifEditor.PageMain;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;
using System.Windows;
using System.Windows.Controls;

using RozaVetrov_TarifEditor.DataFiles.PageData;

namespace RozaVetrov_TarifEditor
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

            MainWindowData.SectionName = TitleTextBlock;
            MainWindowData.SectionName.Text = "Авторизация";
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
        
        private void OpenPriceSiteButton(object sender, RoutedEventArgs e)
            => Link.OpenInBrowser("https://github.com/vgy789/RozaVetrov-Progress/blob/master/docs/price-list.xlsx");

        private void OpenCalcSiteButton(object sender, RoutedEventArgs e)
            => Link.OpenInBrowser("http://localhost:8099/");

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

            [Description("Субъект")]
            Subject,

            [Description("Город")]
            City
        }

        readonly private static Thickness thickness = new Thickness(16, 8, 8, 8);

        /// <summary>
        /// Отображемые названия таблиц в левом выдвижном меню.
        /// </summary>
        readonly private static List<ListBoxItem> _tableCollections = new List<ListBoxItem>
        {
            new ListBoxItem { Content = GetDescription(TablesName.Subject), Padding = thickness, FontSize = 14 },
            new ListBoxItem { Content = GetDescription(TablesName.City), Padding = thickness, FontSize = 14 },
            new ListBoxItem { Content = GetDescription(TablesName.Transportation), Padding = thickness, FontSize = 14}
        };

        private string _seletedItemContext;
        private ListBoxItem _seletedItem;
        private ListBox _itemsHost;

        /// <summary>
        /// Событие указывает на выбраный раздел в правом меню.
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


                try
                {
                    if (_seletedItemContext == GetDescription(TablesName.City))
                    {
                        seletedItemIndex = 1;
                        FrameApp.frameObj.Navigate(new PageCity());
                    }
                    else if (_seletedItemContext == GetDescription(TablesName.Subject))
                    {
                        seletedItemIndex = 0;
                        PrevSectionButton.IsEnabled = false;
                        FrameApp.frameObj.Navigate(new PageSubject());
                    }
                    else if(_seletedItemContext == GetDescription(TablesName.Transportation))
                    {
                        seletedItemIndex = 2;
                        FollowSectionButton.IsEnabled = false;
                        FrameApp.frameObj.Navigate(new PageTransportation());
                    }
                    
                }
                catch (Exception)
                {
                    MessageBox.Show("Не удалось построить соединение с базой данных.");
                    return;
                }
            }

            // Скрыть панель после выбора.
            MenuToggleButton.IsChecked = false;
        }
        #endregion
        
        // открытое окно после авторизации
        int seletedItemIndex = 0;


        private void PrevSectionButton_Click(object sender, RoutedEventArgs e)
        {
            seletedItemIndex -= 1;

            ChangeSection();
        }

        private void FollowSectionButton_Click(object sender, RoutedEventArgs e)
        {
            seletedItemIndex += 1;
            ChangeSection();
        }

        private void ChangeSection()
        {
            if (seletedItemIndex == 1)
            {
                FollowSectionButton.IsEnabled = true;
                PrevSectionButton.IsEnabled = true;
                FrameApp.frameObj.Navigate(new PageCity());
            }
            else if (seletedItemIndex == 0)
            {
                FollowSectionButton.IsEnabled = true;
                PrevSectionButton.IsEnabled = false;
                FrameApp.frameObj.Navigate(new PageSubject());
            }
            else if (seletedItemIndex == 2)
            {
                FollowSectionButton.IsEnabled = false;
                PrevSectionButton.IsEnabled = true;
                FrameApp.frameObj.Navigate(new PageTransportation());
            }
        }

        
    }
}
