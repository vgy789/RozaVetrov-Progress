using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class Package
    {
        public Package()
        {
            PackagePriceTransportation = new HashSet<PackagePriceTransportation>();
        }

        public int PackageId { get; set; }
        public int Value { get; set; }
        public short WeightId { get; set; }
        public short SizeId { get; set; }

        public virtual Size Size { get; set; }
        public virtual Weight Weight { get; set; }
        public virtual ICollection<PackagePriceTransportation> PackagePriceTransportation { get; set; }
    }
}
