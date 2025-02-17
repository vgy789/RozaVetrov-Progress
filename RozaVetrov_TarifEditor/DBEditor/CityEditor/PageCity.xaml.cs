using RozaVetrov_TarifEditor.DataFiles;
using RozaVetrov_TarifEditor.DataFiles.Models;
using RozaVetrov_TarifEditor.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace RozaVetrov_TarifEditor.DBEditor.CityEditor
{
    /// <summary>
    /// Страница для просмотра и редактирования таблицы БД - City.
    /// </summary>
    public partial class PageCity : Page
    {
        public PageCity()
        {
            InitializeComponent();

            MainWindowData.SectionName.Text = "Город";
            DataFiles.PageData.City.DataGrid = CityDataGrid;
            DataFiles.PageData.City.RefreshDataGrid();
            DataFiles.PageData.City.TotalViewItemsLabel = TotalViewCitiesLabel;
            DataFiles.PageData.City.DateLatestChangesLabel = DateLatestChangesLabel;

            DataFiles.PageData.City.RefreshTotalViewValues();
            DataFiles.PageData.City.RefreshDateLatestChangesLabel();

        }

        #region Events
        
        private void AddCityButton_Click(object sender, RoutedEventArgs e)
        {
            ShowWindowAddCity();
        }

        private void EditCity_Click(object sender, RoutedEventArgs e)
        {
            ShowWindowEdit(sender);
        }

        private void DeleteCity_Click(object sender, RoutedEventArgs e)
        {
            DeleteCity(sender);
            DataFiles.PageData.City.RefreshAllElement();
        }        

        private void UpdateButton_Click(object sender, RoutedEventArgs e)
        {
            SearchCities();
            CityDataGrid.Items.Refresh();
        }

        private void SearchBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingString(e);
        }

        private void SearchBox_KeyUp(object sender, KeyEventArgs e)
        {
            SearchCities();
        }

        #endregion

        /// <summary>
        /// Поиск необходимых строк в DataGrid.
        /// </summary>
        private void SearchCities()
        {
            string search_word = SearchBox.Text;
            List<City> transportations = GetSearchedCities(search_word);

            CityDataGrid.ItemsSource = transportations;
            CityDataGrid.Items.Refresh();

            static List<City> GetSearchedCities(string search_word)
            {
                return OdbConnectHelper.dbObj.City.Where(
                    x => x.Name.ToLower()
                    .Contains(search_word.ToLower()))
                    .ToList();
            }
            
        }

        /// <summary>
        /// Открывает окно добаления города.
        /// </summary>
        private static void ShowWindowAddCity()
        {
            try
            {
                WindowModifyCity windowAddCity = new WindowModifyCity();
                windowAddCity.Show();
            }
            catch (Exception ex)
            {
                ExceptionMBox.ShowExceptionError(ex);

                throw;
            }
        }

        /// <summary>
        /// Открывает окно редактирования города, который выбрал пользователь.
        /// </summary>
        /// <param name="sender">Выбранный субъект.</param>
        private static void ShowWindowEdit(object sender)
        {
            try
            {
                City selected_city = (sender as Button).DataContext as City;
                WindowModifyCity windowEditCity = new WindowModifyCity(selected_city);
                windowEditCity.Show();
            }
            catch (Exception ex)
            {
                ExceptionMBox.ShowExceptionError(ex);

                throw;
            }
        }

        /// <summary>
        /// Удаляет город, который выбрал пользователь.
        /// </summary>
        /// <param name="sender">Выбранный город.</param>
        private static void DeleteCity(object sender)
        {
            // TODO: Проверить удаление.
            try
            {
                if (MessageBox.Show("При удалении города все связанные данные (возможные перевозки, минимальная стоимость перевозки, стоимости перевозки по весу и размерам) так-же удалятся!", "Удаление.", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    City selected_city = (sender as Button).DataContext as City;
                    OdbConnectHelper.dbObj.City.Remove(selected_city);

                    DataFiles.PageData.City.SaveChanges();
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
