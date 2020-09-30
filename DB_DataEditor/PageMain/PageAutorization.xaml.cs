using DB_DataEditor.DataFiles;
using DB_DataEditor.Domain;
using DB_DataEditor.Properties;
using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace DB_DataEditor.PageMain
{
    /// <summary>
    /// Логика взаимодействия для PageAutorization.xaml
    /// </summary>
    public partial class PageAutorization : Page
    {
        private static StackPanel _panelVisibility;

        /// <summary>
        /// Инициализация и загрузка из Settings данных о сохраненном логине с прошлой авторизации.
        /// </summary>
        public PageAutorization(StackPanel panelVisibility)
        {
            InitializeComponent();

            _panelVisibility = panelVisibility;
            RememberLoginChkBox.IsChecked = Settings.Default.ChkSaveLogin;
            if (Settings.Default.EventSaveLogin != string.Empty)
                LoginTextBox.Text = Settings.Default.EventSaveLogin;
        }

        /// <summary>
        /// Подключение пользователя к базе даных.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param> 
        private void GetInButton_Click(object sender, RoutedEventArgs e)
        {
            RememberLogin(RememberLoginChkBox.IsChecked == true);
            try
            {
                FrameApp.frameObj.Navigate(new PageDBEditor());

                _panelVisibility.Visibility = Visibility.Visible;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка работы приложения: " + ex.Message.ToString(), "Критический сбой",
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                throw;
            }
        }

        /// <summary>
        /// Запоминать-ли логин пользователя.
        /// </summary>
        private void RememberLogin(bool isRememberLogin)
        {
            string textLogin = LoginTextBox.Text;

            Settings.Default.ChkSaveLogin = isRememberLogin;
            if (isRememberLogin == true)
                Settings.Default.EventSaveLogin = textLogin;
            else
                Settings.Default.EventSaveLogin = "";
      
            Settings.Default.Save();
        }

    }
}