using RozaVetrov_TarifEditor.DataFiles;
using RozaVetrov_TarifEditor.DataFiles.Models;
using RozaVetrov_TarifEditor.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace RozaVetrov_TarifEditor.DBEditor.SubjectEditor
{
    /// <summary>
    /// Страница для просмотра и редактирования таблицы БД - City.
    /// </summary>
    public partial class PageSubject : Page
    {
        public PageSubject()
        {
            InitializeComponent();

            MainWindowData.SectionName.Text = "Субъект";
            DataFiles.PageData.Subject.DataGrid = SubjectDataGrid;
            DataFiles.PageData.Subject.RefreshDataGrid();
            DataFiles.PageData.Subject.TotalViewItemsLabel = TotalViewSubjectsLabel;
            DataFiles.PageData.Subject.DateLatestChangesLabel = DateLatestChangesLabel;

            DataFiles.PageData.Subject.RefreshTotalViewValues();
            DataFiles.PageData.Subject.RefreshDateLatestChangesLabel();
        }

    #region Events
        private void SearchBox_KeyUp(object sender, KeyEventArgs e)
        {
            SearchSubjects();
        }

        private void AddSubjectButton_Click(object sender, RoutedEventArgs e)
        {
            ShowWindowAdd();
        }
        
        private void EditSubject_Click(object sender, RoutedEventArgs e)
        {
            ShowWindowEdit(sender);
        }

        private void DeleteSubject_Click(object sender, RoutedEventArgs e)
        {
            DeleteSubject(sender);
            DataFiles.PageData.Subject.RefreshAllElement();
        }
        
        private void SearchBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingString(e);
        }

        private void UpdateButton_Click(object sender, RoutedEventArgs e)
        {
            SearchSubjects();
            SubjectDataGrid.Items.Refresh();
        }

    #endregion

        /// <summary>
        /// Поиск необходимых строк в DataGrid.
        /// </summary>
        private void SearchSubjects()
        {
            string search_word = SearchBox.Text;

            SubjectDataGrid.ItemsSource = GetSearchedSubjects(search_word);
            SubjectDataGrid.Items.Refresh();

            static List<Subject> GetSearchedSubjects(string text)
            {
                return OdbConnectHelper.dbObj.Subject.Where(
                    x => x.Name.ToLower()
                    .Contains(text.ToLower()))
                    .ToList();
            }
        }

        /// <summary>
        /// Открывает окно добаления субъекта.
        /// </summary>
        private static void ShowWindowAdd()
        {
            WindowModifySubject windowModifySubject = new WindowModifySubject();
            windowModifySubject.Show();
        }

        /// <summary>
        /// Открывает окно редактирования субъекта, который выбрал пользователь.
        /// </summary>
        /// <param name="sender">Выбранный субъект.</param>
        private static void ShowWindowEdit(object sender)
        {
            try
            {
                Subject selected_subject = (sender as Button).DataContext as Subject;
                WindowModifySubject windowModifySubject = new WindowModifySubject(selected_subject);
                windowModifySubject.ShowDialog();
            }
            catch (Exception ex)
            {
                ExceptionMBox.ShowExceptionError(ex);

                throw;
            }
        }
        
        /// <summary>
        /// Удаляет субъект и связанные с ним данные, который выбрал пользователь.
        /// </summary>
        /// <param name="sender">Выбранный субъект.</param>
        private static void DeleteSubject(object sender)
        {
            try
            {
                string message = "При удалении субъекта все его связанные данные " +
                    "(города, возможные перевозки по городам, минимальная стоимость перевозки, " +
                    "стоимости перевозки по весу и размерам так-же удалятся!";
                if (MessageBox.Show(message, "Удаление.", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    Subject selected_subject = (sender as Button).DataContext as Subject;
                    Subject subject = selected_subject;
                    OdbConnectHelper.dbObj.Subject.Remove(subject);

                    DataFiles.PageData.Subject.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                ExceptionMBox.ShowExceptionError(ex);

                throw;
            }
        }
    }
}
