using DB_DataEditor.DataFiles.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace DB_DataEditor.DataFiles
{
    /// <summary>
    /// Хранит соединение с базой данных.
    /// </summary>
    class OdbConnectHelper
    {
        public static roza_vetrovContext dbObj = new roza_vetrovContext("" +
            "192.168.0.123", "5432", "roza_vetrov", "postgres", "Sobaki@@");
    }
}
