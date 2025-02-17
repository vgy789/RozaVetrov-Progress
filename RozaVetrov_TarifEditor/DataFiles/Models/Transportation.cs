using System;
using System.Collections.Generic;

namespace RozaVetrov_TarifEditor.DataFiles.Models
{
    public partial class Transportation
    {
        public Transportation()
        {
            MinimalWeightPrice = new HashSet<MinimalWeightPrice>();
            SizeCoefficient = new HashSet<SizeCoefficient>();
            WeightCoefficient = new HashSet<WeightCoefficient>();
        }

        public int TransportationId { get; set; }
        public short IncityId { get; set; }
        public short FromcityId { get; set; }

        public virtual City Fromcity { get; set; }
        public virtual City Incity { get; set; }
        public virtual ICollection<MinimalWeightPrice> MinimalWeightPrice { get; set; }
        public virtual ICollection<SizeCoefficient> SizeCoefficient { get; set; }
        public virtual ICollection<WeightCoefficient> WeightCoefficient { get; set; }
    }
}
