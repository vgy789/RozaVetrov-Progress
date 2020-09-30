using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class MinimalPriceTransportation
    {
        public MinimalPriceTransportation()
        {
            PriceNavigation = new HashSet<Price>();
        }

        public int MinimalPriceTransportationId { get; set; }
        public int TransportationId { get; set; }
        public int Price { get; set; }

        public virtual Transportation Transportation { get; set; }
        public virtual ICollection<Price> PriceNavigation { get; set; }
    }
}
