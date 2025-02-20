using RozaVetrov_TarifEditor.DataFiles.Models;
using System;
using System.Windows;

namespace RozaVetrov_TarifEditor.DataFiles
{
    /// <summary>
    /// Хранит соединение с базой данных.
    /// </summary>
    class OdbConnectHelper
    {
        private static roza_vetrovContext _dbObj;
        public static roza_vetrovContext dbObj 
        {
            get 
            {
                if (_dbObj == null)
                {
                    try
                    {
                        _dbObj = new roza_vetrovContext();
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Database connection error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
                return _dbObj;
            }
        }
    }
}
