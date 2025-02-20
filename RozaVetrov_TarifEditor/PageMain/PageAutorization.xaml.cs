using RozaVetrov_TarifEditor.DataFiles;
using RozaVetrov_TarifEditor.Properties;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Linq;


namespace RozaVetrov_TarifEditor.PageMain
{
    /// <summary>
    /// Страница для авторизации пользователя.
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

        private void GetInButton_Click(object sender, RoutedEventArgs e)
        {
            GetIn();
        }

        /// <summary>
        /// Запоминать-ли логин пользователя для будущего входа.
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

        /// <summary>
        /// Авторизация пользователя, открытие страницы редактора БД, применение других настроек.
        /// </summary>
        private void GetIn()
        {
            try
            {
                if (string.IsNullOrWhiteSpace(LoginTextBox.Text) || string.IsNullOrWhiteSpace(PasswordPasswordBox.Password))
                {
                    MessageBox.Show("Please enter both login and password", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                RememberLogin(IsRememberLogin());

                if (DBConnecting())
                {
                    OpenDBEditor();
                }
                else
                {
                    MessageBox.Show("Invalid login or password", "Authentication Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error during authentication: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        /// <summary>
        /// Проверяет нужно-ли сохранять пароль.
        /// </summary>
        /// <returns></returns>
        private bool IsRememberLogin()
        {
            return RememberLoginChkBox.IsChecked == true;
        }

        /// <summary>
        /// Авторизация пользователя.
        /// </summary>
        /// <returns></returns>
        private bool DBConnecting()
        {
            if (OdbConnectHelper.dbObj == null)
                return false;

            var user = OdbConnectHelper.dbObj.User
                .FirstOrDefault(x => x.Login == LoginTextBox.Text && x.Password == PasswordPasswordBox.Password);
            return user != null;
        }

        /// <summary>
        /// Открывает окно редактора данных таблиц БД.
        /// </summary>
        private void OpenDBEditor()
        {
            FrameApp.frameObj.Navigate(new DBEditor.SubjectEditor.PageSubject());
            _panelVisibility.Visibility = Visibility.Visible;
        }
    }
}
