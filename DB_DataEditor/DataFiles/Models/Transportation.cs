using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class Transportation
    {
        public Transportation()
        {
            MinimalPriceTransportation = new HashSet<MinimalPriceTransportation>();
            PackagePriceTransportation = new HashSet<PackagePriceTransportation>();
        }

        public int TransportationId { get; set; }
        public short IncityId { get; set; }
        public short FromcityId { get; set; }

        public virtual City Fromcity { get; set; }
        public virtual City Incity { get; set; }
        public virtual ICollection<MinimalPriceTransportation> MinimalPriceTransportation { get; set; }
        public virtual ICollection<PackagePriceTransportation> PackagePriceTransportation { get; set; }
    }
}
