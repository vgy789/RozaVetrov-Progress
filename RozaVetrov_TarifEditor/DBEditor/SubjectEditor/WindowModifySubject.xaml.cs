using RozaVetrov_TarifEditor.DataFiles;
using RozaVetrov_TarifEditor.DataFiles.Models;
using RozaVetrov_TarifEditor.Domain;
using System;
using System.Linq;
using System.Windows;
using System.Windows.Input;

namespace RozaVetrov_TarifEditor.DBEditor.SubjectEditor
{
    /// <summary>
    /// Окно изменения данных в таблице БД - Subject.
    /// </summary>
    public partial class WindowModifySubject : Window
    {
        /// <summary>
        /// Возможные режимы окна
        /// </summary>
        private enum Mode
        {
            CreateSubject,
            EditSubject
        }

        /// <summary>
        /// Текущий режим открытого окна.
        /// </summary>
        private readonly Mode ActiveMode = new Mode();

        private readonly Subject _selectedSubject = null;
        
        public WindowModifySubject(Subject selectedSubject = null)
        {
            InitializeComponent();

            if (selectedSubject == null)
            {
                ActiveMode = Mode.CreateSubject;
            }
            else
            {
                ActiveMode = Mode.EditSubject;
                _selectedSubject = selectedSubject;
            }

            CustomizeInitialViewWindow();
        }
    #region Events
        private void Window_KeyUp(object sender, KeyEventArgs e)
        {
            if (IsKeyEnter(e))
            {
                ModifySubject();
                DataFiles.PageData.Subject.RefreshDataGrid();
            }
            return;
        }

        private void ModifySubjectButton_Click(object sender, RoutedEventArgs e)
        {
            ModifySubject();

            DataFiles.PageData.Subject.RefreshAllElement();
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
            if (ActiveMode == Mode.CreateSubject)
            {
                Title = "Добавить новый субъект";
                ModifySubjectButton.Content = "Добавить";
            }
            if (ActiveMode == Mode.EditSubject)
            {
                Title = "Изменить параметры субъека: " + _selectedSubject.Name;
                NameTextBox.Text = _selectedSubject.Name;
                ModifySubjectButton.Content = "Изменить";
            }

            NameTextBox.Focus();
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
        private void ModifySubject()
        {
            try
            {
                string introduced_subject = NameTextBox.Text.Trim();
                if (introduced_subject == "" || NameTextBox.Text.Length < 5)
                {
                    MessageBox.Show("Название субъекта не введено.");
                    return;
                }
                string? find_name = OdbConnectHelper.dbObj.Subject.FirstOrDefault(x => x.Name == introduced_subject)?.Name;
                if (find_name != null)
                {
                    MessageBox.Show("Такой субъект уже есть в базе данных.");
                    return;
                }

                try
                {
                    if (ActiveMode == Mode.CreateSubject)
                    {
                        OdbConnectHelper.dbObj.Subject.Add(new Subject { Name = introduced_subject });
                    }
                    else
                    {
                        OdbConnectHelper.dbObj.Subject.FirstOrDefault(x => x.SubjectId == _selectedSubject.SubjectId).Name = introduced_subject;
                    }
                    DataFiles.PageData.Subject.SaveChanges();
                }
                catch (Exception)
                {

                    throw;
                }
                
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
