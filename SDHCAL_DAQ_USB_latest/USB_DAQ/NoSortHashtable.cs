using System.Collections; //new add 20150809
namespace USB_DAQ
{
    class NoSortHashtable : Hashtable
    {
        private ArrayList keys = new ArrayList();
        public NoSortHashtable() { }
        public override void Add(object key, object value)
        {
            base.Add(key, value);
            keys.Add(key);
        }
        public override void Clear()
        {
            base.Clear();
            keys.Clear();
        }
        public override void Remove(object key)
        {
            base.Remove(key);
            keys.Remove(key);
        }
        public override ICollection Keys
        {
            get
            {
                //return base.Keys;
                return keys;
            }
        }
        public override IDictionaryEnumerator GetEnumerator()
        {
            return base.GetEnumerator();
        }
    }
}
