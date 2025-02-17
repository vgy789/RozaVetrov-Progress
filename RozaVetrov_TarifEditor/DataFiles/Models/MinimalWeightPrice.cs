using System;
using System.Collections.Generic;

namespace RozaVetrov_TarifEditor.DataFiles.Models
{
    public partial class MinimalWeightPrice
    {
        public int MinWeightPriceId { get; set; }
        public int TransportationId { get; set; }
        public short Price { get; set; }

        public virtual Transportation Transportation { get; set; }
    }
}
