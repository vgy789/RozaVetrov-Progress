using System;
using System.Collections.Generic;

namespace RozaVetrov_TarifEditor.DataFiles.Models
{
    public partial class Size
    {
        public Size()
        {
            SizeCoefficient = new HashSet<SizeCoefficient>();
        }

        public short SizeId { get; set; }
        public string Name { get; set; }

        public virtual ICollection<SizeCoefficient> SizeCoefficient { get; set; }
    }
}
