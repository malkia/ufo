   namespace std {
   template <class T>
   inline const T& min(const T& a, const T& b) {
       return b < a ? b : a;
   }
   template <class T, class Compare>
   inline const T& min(const T& a, const T& b, Compare comp) {
       return comp(b, a) ? b : a;
   }
   template <class T>
   inline const T& max(const T& a, const T& b) {
       return  a < b ? b : a;
   }
   template <class T, class Compare>
   inline const T& max(const T& a, const T& b, Compare comp) {
       return comp(a, b) ? b : a;
   }
}