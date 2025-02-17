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
            RememberLogin(IsRememberLogin());


            if (DBConnecting() == true)
            {
                OpenDBEditor();
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
            return OdbConnectHelper.dbObj.User.Any(x => x.Login == LoginTextBox.Text) &&
                OdbConnectHelper.dbObj.User.Any(x => x.Password == PasswordPasswordBox.Password);
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
