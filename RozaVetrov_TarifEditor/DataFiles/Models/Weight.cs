using System;
using System.Collections.Generic;

namespace RozaVetrov_TarifEditor.DataFiles.Models
{
    public partial class Weight
    {
        public Weight()
        {
            WeightCoefficient = new HashSet<WeightCoefficient>();
        }

        public short WeightId { get; set; }
        public string Name { get; set; }

        public virtual ICollection<WeightCoefficient> WeightCoefficient { get; set; }
    }
}
