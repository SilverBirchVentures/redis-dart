part of redis;
/*
 * Free software licenced under 
 * GNU AFFERO GENERAL PUBLIC LICENSE
 * 
 * Check for document LICENCE forfull licence text
 * 
 * Luka Rahne
 */


Utf8Encoder RedisSerialiseEncoder = new Utf8Encoder();

class RedisBulk{
  Iterable<int> iterable;
  /// This clase enables sending Iterable<int> 
  /// as bulk data on redis
  /// it can be used when sending files for example
  RedisBulk(this.iterable){
  }
}


class RedisSerialise {
  static final  _dollar = ascii.encode("\$");
  static final  _star = ascii.encode("\*");
  static final  _semicol  = ascii.encode(":");
  static final _linesep = ascii.encode("\r\n");
  static final _dollarminus1 = ascii.encode("\$-1");
  static final List _ints = new List.generate(20,(i)=>ascii.encode(i.toString()),growable:false);

      
  static List<int> Serialise(object){
     List<int> s = new List();
     SerialiseConsumable(object,(v){
       s.addAll(v);
     });
     return s;
  }
  
  static void SerialiseConsumable(object,Function consumer(Iterable s)){
     if(object is String){
       var data = utf8.encode(object);
       consumer(_dollar);
       consumer(_IntToRaw(data.length));
       consumer(_linesep); 
       consumer(data);
       consumer(_linesep);
     }
     else if(object is Iterable){
       int len=object.length;
       consumer(_star);
       consumer(_IntToRaw(len));
       consumer(_linesep);
       object.forEach((v)=>SerialiseConsumable(v,consumer));
     }
     else if(object is int){
       consumer(_semicol);
       consumer(_IntToRaw(object));
       consumer(_linesep);
     }
     else if(object is RedisBulk){
       consumer(_dollar);
       consumer(_IntToRaw(object.iterable.length));
       consumer(_linesep);
       consumer(object.iterable);
     }
     else if(object == null){
       consumer(_dollarminus1); //null bulk
     }
     else{
       throw("cant serialise such type");
     }
  }
  
  static Iterable<int> _IntToRaw(int n){
    //if(i>=0 && i < _ints.length)
    //   return _ints[i];
    return ascii.encode(n.toString());
  }
}