public with sharing class DataTypeTest {
  @AuraEnabled
  public Integer dt_integer;

  @AuraEnabled
  public String dt_string;

  @AuraEnabled
  public Decimal dt_decimal;

  @AuraEnabled
  public List<String> dt_list_string;

  // ******************************
  // Set Implementation
  // ******************************
  public Set<String> string_set = new Set<String>();

  @AuraEnabled
  public String addToStringSet {
    set {
      string_set.add(value);
    }
  }

  @AuraEnabled
  public List<String> string_set_to_list {
    get {
      return new List<String>(string_set);
    }
  }

  // ******************************
  // Map Counter Implementation
  // ******************************
  public Map<String, Integer> counter_map = new Map<String, Integer>();

  @AuraEnabled
  public Integer map_value;

  @AuraEnabled
  public String map_key;

  @AuraEnabled
  public String setMapKey {
    set {
      map_key = value;
      map_value = (counter_map.get(value) ?? 0);
    }
  }

  @AuraEnabled
  public String addToCounterMap {
    set {
      counter_map.put(value, (counter_map.get(value) ?? 0) + 1);
    }
  }
}