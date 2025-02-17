using System;
using System.Collections.Generic;

namespace RozaVetrov_TarifEditor.DataFiles.Models
{
    public partial class History
    {
        public short HistoryId { get; set; }
        public DateTime DateEvent { get; set; }
        public string TableName { get; set; }
        public string Status { get; set; }
    }
}
