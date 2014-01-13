part of contactserver.database;

Future<Map> getOrganizationContactList(int organizationId) {
  String sql = '''
    SELECT orgcon.organization_id, 
           orgcon.contact_id, 
           orgcon.wants_messages, 
           orgcon.attributes, 
           orgcon.enabled as orgenabled, 
           con.full_name, 
           con.contact_type, 
           con.enabled as conenabled
    FROM contacts con 
      JOIN organization_contacts orgcon on con.id = orgcon.contact_id
    WHERE orgcon.organization_id = @orgid''';
  
  Map parameters = {'orgid' : organizationId};

  return database.query(_pool, sql, parameters).then((rows) {
    List contacts = new List();
    for(var row in rows) {
      Map contact =
        {'organization_id'      : row.organization_id,
         'contact_id'           : row.contact_id,
         'wants_messages'       : row.wants_messages,
         'organization_enabled' : row.orgenabled,
         'contact_enabled'      : row.conenabled,
         'full_name'            : row.full_name,
         'contact_type'         : row.contact_type};

      if (row.attributes != null) {
        Map attributes = JSON.decode(row.attributes);
        if(attributes != null) {
          attributes.forEach((key, value) => contact.putIfAbsent(key, () => value));
        }
      }
      contacts.add(contact);
    }

    return {'contacts': contacts};
  });
}
