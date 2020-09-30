using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class Size
    {
        public Size()
        {
            Package = new HashSet<Package>();
        }

        public short SizeId { get; set; }
        public string Name { get; set; }

        public virtual ICollection<Package> Package { get; set; }
    }
}
