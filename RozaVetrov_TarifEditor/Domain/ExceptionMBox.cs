using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;

namespace RozaVetrov_TarifEditor.Domain
{
    static class ExceptionMBox
    {
        public static void ShowExceptionError(Exception e)
        {
            MessageBox.Show("Ошибка работы приложения: " + e.Message.ToString(), "Критический сбой",
                MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        
    }
}
