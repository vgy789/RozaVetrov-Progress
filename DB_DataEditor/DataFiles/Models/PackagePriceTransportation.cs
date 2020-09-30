using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class PackagePriceTransportation
    {
        public PackagePriceTransportation()
        {
            PriceNavigation = new HashSet<Price>();
        }

        public int PackagePriceTransportationId { get; set; }
        public int TransportationId { get; set; }
        public int PackageId { get; set; }
        public float Price { get; set; }

        public virtual Package Package { get; set; }
        public virtual Transportation Transportation { get; set; }
        public virtual ICollection<Price> PriceNavigation { get; set; }
    }
}
