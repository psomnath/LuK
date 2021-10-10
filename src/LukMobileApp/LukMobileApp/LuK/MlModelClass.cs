using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace LuK
{
    public class MlModelClass : IMLModel
    {
        public async Task<bool> FindMatch(List<AmberAlert> amberAlerts)
        {
            // scan through the licence plate numbers in the alerts list and match the numbers with the stream of incoming images. 
            return true;
        }
    }
}
