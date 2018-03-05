using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace USB_DAQ
{
    class MicrorocControl
    {
        public MicrorocControl( int asicID)
        {
            AsicID = asicID;
        }
        public int AsicID { set; get; }
    }
}
