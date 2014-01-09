part of organizationserver.db;

Future<Map> getOrganizationCalendarList(int organizationId) {
  return _pool.connect().then((Connection conn) {
    String sql = '''
SELECT cal.id, cal.start, cal.stop, cal.message
FROM calendar_events cal join organization_calendar org on cal.id = org.event_id
WHERE org.organization_id = @orgid''';
    
    Map parameters = {'orgid' : organizationId};

    return conn.query(sql, parameters).toList().then((rows) {
      List contacts = new List();
      for(var row in rows) {
        Map contact =
          {'id'      : row.id,
           'start'   : row.start,
           'stop'    : row.stop,
           'message' : row.message};
        contacts.add(contact);
      }

      Map data = {'CalendarEvents': contacts};

      return data;
    }).whenComplete(() => conn.close());
  });
}
