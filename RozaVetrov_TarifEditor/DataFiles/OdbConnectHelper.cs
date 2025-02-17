using RozaVetrov_TarifEditor.DataFiles.Models;

namespace RozaVetrov_TarifEditor.DataFiles
{
    /// <summary>
    /// Хранит соединение с базой данных.
    /// </summary>
    class OdbConnectHelper
    {
        public static roza_vetrovContext dbObj = new roza_vetrovContext();
    }
}
