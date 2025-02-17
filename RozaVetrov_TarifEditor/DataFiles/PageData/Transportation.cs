using System.Linq;
using System.Text;
using System.Windows.Controls;

namespace RozaVetrov_TarifEditor.DataFiles.PageData
{
    class Transportation : IPageData
    {
        /// <summary>
        /// Таблица отображаемая в данный момет.
        /// </summary>
        public static DataGrid DataGrid { get; set; }

        /// <summary>
        /// Количество строк отображемых в данный момент.
        /// </summary>
        public static Label TotalViewItemsLabel { get; set; }

        /// <summary>
        /// Обновление числа - количества показываемых элементов в DataGrid.
        /// </summary>
        public static void RefreshTotalViewValues()
        {
            TotalViewItemsLabel.Content = DataGrid.Items.Count.ToString();
        }

        /// <summary>
        /// Сохранение изменений в базе данных.
        /// </summary>
        public static void SaveChanges()
        {
            OdbConnectHelper.dbObj.SaveChanges();
        }

        /// <summary>
        /// Загрузка данных в DataGrid из базы данных.
        /// </summary>
        public static void RefreshDataGrid()
        {
            var a = OdbConnectHelper.dbObj.City.ToList();
            DataGrid.ItemsSource = OdbConnectHelper.dbObj.Transportation.ToList();
        }

        /// <summary>
        /// Дата последнего изменения отображаемая в данный момент.
        /// </summary>
        public static Label DateLatestChangesLabel { get; set; }

        public static void RefreshDateLatestChangesLabel()
        {
            //string latestChange = null;
            var latestChange = OdbConnectHelper.dbObj.History.OrderByDescending(x => x.DateEvent).FirstOrDefault()?.DateEvent;

            if (latestChange == null)
            {
                DateLatestChangesLabel.Content = "Нет информации о последних изменениях";
                return;
            }
            DateLatestChangesLabel.Content = latestChange.ToString();
        }

        /// <summary>
        /// Обновляет все изменяемые (кроме textbox) элементы страницы.
        /// </summary>
        public static void RefreshAllElement()
        {
            RefreshDataGrid();
            RefreshTotalViewValues();
            RefreshDateLatestChangesLabel();
        }
    }
}
