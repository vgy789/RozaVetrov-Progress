using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class Weight
    {
        public Weight()
        {
            Package = new HashSet<Package>();
        }

        public short WeightId { get; set; }
        public string Name { get; set; }

        public virtual ICollection<Package> Package { get; set; }
    }
}
