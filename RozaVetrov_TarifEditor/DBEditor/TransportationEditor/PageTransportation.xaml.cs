using RozaVetrov_TarifEditor.DataFiles;
using RozaVetrov_TarifEditor.DataFiles.Models;
using RozaVetrov_TarifEditor.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace RozaVetrov_TarifEditor.DBEditor.TransportationEditor
{
    /// <summary>
    /// Логика взаимодействия для PageTransportation.xaml
    /// </summary>
    public partial class PageTransportation : Page
    {
        public PageTransportation()
        {
            InitializeComponent();
            MainWindowData.SectionName.Text = "Транспортировка";
            DataFiles.PageData.Transportation.DataGrid = TransportationDataGrid;
            DataFiles.PageData.Transportation.RefreshDataGrid();
            DataFiles.PageData.Transportation.TotalViewItemsLabel = TotalViewTransportationsLabel;
            DataFiles.PageData.Transportation.DateLatestChangesLabel = DateLatestChangesLabel;

            DataFiles.PageData.Transportation.RefreshTotalViewValues();
            DataFiles.PageData.Transportation.RefreshDateLatestChangesLabel();
            
        }

        #region Events
        private void AddTransportationButton_Click(object sender, RoutedEventArgs e)
        {
            ShowWindowAddTransportation();
        }

        private void EditTransportation_Click(object sender, RoutedEventArgs e)
        {
            ShowWindowEditTransportation(sender);
        }

        private void DeleteTransportation_Click(object sender, RoutedEventArgs e)
        {
            DeleteTransportation(sender);
            DataFiles.PageData.Transportation.RefreshAllElement();
        }

        private void UpdateButton_Click(object sender, RoutedEventArgs e)
        {
            SearchItems();
        }

        private void FromSearchBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingString(e);
        }

        private void InSearchBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingString(e);
        }

        private void FromSearchBox_KeyUp(object sender, KeyEventArgs e)
        {
            SearchItems();
        }

        private void InSearchBox_KeyUp(object sender, KeyEventArgs e)
        {
            SearchItems();
        }

        private void SwapCitiesButton_Click(object sender, RoutedEventArgs e)
        {
            SwapCities();
        }
        #endregion



        /// <summary>
        /// Поиск необходимых строк в DataGrid.
        /// </summary>
        private void SearchItems()
        {
            string from_text = FromSearchBox.Text.Trim();
            string in_text = InSearchBox.Text.Trim();

            List<Transportation> transportations = GetSearchedItems(from_text, in_text);

            TransportationDataGrid.ItemsSource = transportations;
            TransportationDataGrid.Items.Refresh();

            static List<Transportation> GetSearchedItems(string from_text, string in_text)
            {
                if (from_text == "" && in_text == "")
                    return OdbConnectHelper.dbObj.Transportation.ToList();
                
                if (from_text != "" && in_text == "")
                    return OdbConnectHelper.dbObj.Transportation.Where(
                        x => x.Fromcity.Name.ToLower().Contains(from_text.ToLower())
                        ).ToList();
                
                if (from_text == "" && in_text != "")
                    return OdbConnectHelper.dbObj.Transportation.Where(
                        x => x.Incity.Name.ToLower().Contains(in_text.ToLower())
                        ).ToList();

                // if (from_text != "" && in_text != "")
                {
                    return OdbConnectHelper.dbObj.Transportation.Where(
                        x => 
                            x.Fromcity.Name.ToLower().Contains(from_text.ToLower()) 
                            && 
                            x.Incity.Name.ToLower().Contains(in_text.ToLower())
                        ).ToList();
                }    
                    
            }
        }

        /// <summary>
        /// Открывает окно добаления транспортировки.
        /// </summary>
        private static void ShowWindowAddTransportation()
        {
            WindowModifyTransportation windowAddTransportation = new WindowModifyTransportation();
            windowAddTransportation.Show();
        }

        /// <summary>
        /// Открывает окно редактирования транспортировки, который выбрал пользователь.
        /// </summary>
        /// <param name="sender">Выбранный субъект.</param>
        private static void ShowWindowEditTransportation(object sender)
        {
            Transportation selected_transportation = (sender as Button).DataContext as Transportation;
            WindowModifyTransportation windowEditTransportation = new WindowModifyTransportation(selected_transportation);
            windowEditTransportation.Show();
        }

        /// <summary>
        /// Удаляет транспортировку, которую выбрал пользователь.
        /// </summary>
        /// <param name="sender">Выбранный субъект.</param>
        private static void DeleteTransportation(object sender)
        {
            // TODO: Проверь
            try
            {
                if (MessageBox.Show("При удалении города все связанные данные (возможные перевозки, минимальная стоимость перевозки, стоимости перевозки по весу и размерам) так-же удалятся!", "Удаление.", MessageBoxButton.OKCancel, MessageBoxImage.Warning) == MessageBoxResult.OK)
                {
                    Transportation select_transportation = (sender as Button).DataContext as Transportation;
                        /*
                    var rmMinWeightPrice = OdbConnectHelper.dbObj.MinimalWeightPrice.FirstOrDefault(x => x.Transportation == select_transportation);
                    OdbConnectHelper.dbObj.MinimalWeightPrice.Remove(rmMinWeightPrice);

                    var rmWeightPrice = OdbConnectHelper.dbObj.WeightPrice.Where(x => x.Transportation == select_transportation);
                    OdbConnectHelper.dbObj.WeightPrice.RemoveRange(rmWeightPrice);

                    var rmSizePrice = OdbConnectHelper.dbObj.SizePrice.Where(x => x.Transportation == select_transportation);
                    OdbConnectHelper.dbObj.SizePrice.RemoveRange(rmSizePrice);
                    */
                    OdbConnectHelper.dbObj.Transportation.Remove(select_transportation);

                    DataFiles.PageData.Transportation.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                ExceptionMBox.ShowExceptionError(ex);

                throw;
            }
        }

        /// <summary>
        /// Меняет местами текст в FromSearchBox и InSearchBox и обновляет данные в отображаемой таблице.
        /// </summary>
        private void SwapCities()
        {
            SwapText(FromSearchBox, InSearchBox);
            SearchItems();

            /// <summary>
            /// Меняет местами текст в FromSearchBox и InSearchBox.
            /// </summary>
            static void SwapText(TextBox textBox1, TextBox textBox2)
            {
                string text1_bufer = textBox1.Text;

                textBox1.Text = textBox2.Text;
                textBox2.Text = text1_bufer;
            }
        }
    }
}
