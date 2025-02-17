using RozaVetrov_TarifEditor.DataFiles;
using RozaVetrov_TarifEditor.DataFiles.Models;
using RozaVetrov_TarifEditor.Domain;
using System;
using System.Linq;
using System.Windows;
using System.Windows.Input;

namespace RozaVetrov_TarifEditor.DBEditor.CityEditor
{
    /// <summary>
    /// Окно изменения данных в таблице БД - City.
    /// </summary>
    public partial class WindowModifyCity: Window
    {
        /// <summary>
        /// Возможные режимы окна
        /// </summary>
        private enum Mode
        {
            CreateCity,
            EditCity
        }

        /// <summary>
        /// Текущий режим открытого окна.
        /// </summary>
        private readonly Mode ActiveMode = new Mode();

        private readonly City _selectedCity = null;

        public WindowModifyCity(City selectedCity = null)
        {
            InitializeComponent();

            if (selectedCity == null)
            {
                ActiveMode = Mode.CreateCity;
            }
            else
            {
                ActiveMode = Mode.EditCity;
                _selectedCity = selectedCity;
            }

            CustomizeInitialViewWindow();
        }

        #region Events
        private void Window_KeyUp(object sender, KeyEventArgs e)
        {
            if (IsKeyEnter(e))
            {
                ModifyCity();
                DataFiles.PageData.City.RefreshDataGrid();
            }
            return;
        }

        private void ModifyCityButton_Click(object sender, RoutedEventArgs e)
        {
            ModifyCity();
            // TODO: Везде должно быть так и именно здесь.
            DataFiles.PageData.City.RefreshAllElement();
        }

        private void SubjectComboBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingString(e);
        }

        private void NameTextBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingString(e);
        }
        #endregion

        /// <summary>
        /// Стартовая настройка свойств отображаемых элементов.
        /// </summary>
        private void CustomizeInitialViewWindow()
        {
            if (ActiveMode == Mode.CreateCity)
            {
                Title = "Добавить новый город";
                ModifyCityButton.Content = "Добавить";
            }
            if (ActiveMode == Mode.EditCity)
            {
                Title = "Изменить параметры города: " + _selectedCity.Name;
                NameTextBox.Text = _selectedCity.Name;
                ModifyCityButton.Content = "Изменить";
            }
            SettingSubjectComboBox();

            NameTextBox.Focus();

           
            void SettingSubjectComboBox()
            {
                SubjectComboBox.SelectedValuePath = "Subject_id";
                SubjectComboBox.DisplayMemberPath = "Name";
                SubjectComboBox.ItemsSource = OdbConnectHelper.dbObj.Subject.OrderBy(x => x.Name).ToList();

                if (ActiveMode == Mode.EditCity)
                {
                    SubjectComboBox.SelectedItem = _selectedCity.Subject;
                }
                    
            }
        }

        /// <summary>
        /// Проверка на нажетие клавиши "Enter".
        /// </summary>
        /// <param name="e"></param>
        /// <returns></returns>
        private static bool IsKeyEnter(KeyEventArgs e)
        {
            return (e.Key == Key.Enter); 
        }

        /// <summary>
        /// Изменить значение в таблице базы данных.
        /// </summary>
        private void ModifyCity()
        {
            
            string introduced_city = NameTextBox.Text.Trim();
            if (introduced_city == "" || NameTextBox.Text.Length < 2)
            {
                MessageBox.Show("Название города не введено.");
                return;
            }

            Subject selected_subject = SubjectComboBox.SelectedItem as Subject;
            if (selected_subject == null)
            {
                // TODO: Проверить на ввод непонятного субъекта. яяяяяяяяяяя 66666666
                MessageBox.Show("Субъект не выбран.");
                return;
            }

            

            try
            {
                if (ActiveMode == Mode.CreateCity)
                {
                    // TODO: В 1 стране могут быть 2 одинаковых названия города. Нужна проверка на субъект.
                    string? find_name = OdbConnectHelper.dbObj.City.FirstOrDefault(x => x.Name == introduced_city)?.Name;
                    if (find_name != null)
                    {
                        MessageBox.Show("Такой город уже есть в базе данных.");
                        return;
                    }

                    City city = new City()
                    {
                        Name = introduced_city,
                        Subject = selected_subject
                    };

                    OdbConnectHelper.dbObj.City.Add(city);
                }
                if (ActiveMode == Mode.EditCity)
                {
                    OdbConnectHelper.dbObj.City.FirstOrDefault(x => x.CityId == _selectedCity.CityId).Name = introduced_city;
                    OdbConnectHelper.dbObj.City.FirstOrDefault(x => x.CityId == _selectedCity.CityId).Subject = selected_subject;
                }

                DataFiles.PageData.City.SaveChanges();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка работы приложения: " + ex.Message.ToString(), "Критический сбой",
                    MessageBoxButton.OK, MessageBoxImage.Warning);

                throw;
            }
        }

    }
}
