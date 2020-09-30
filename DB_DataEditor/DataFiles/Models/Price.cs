using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class Price
    {
        public int PriceId { get; set; }
        public int MinimalPriceTransportationId { get; set; }
        public int PackagePriceTransportationId { get; set; }
        public float Price1 { get; set; }

        public virtual MinimalPriceTransportation MinimalPriceTransportation { get; set; }
        public virtual PackagePriceTransportation PackagePriceTransportation { get; set; }
    }
}
