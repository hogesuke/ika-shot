class Result < ActiveRecord::Base
  def self.get_max_continuity
    sql = ['SELECT result,',
           '  max(continuity_count) AS continuity_count',
           'FROM (SELECT min(date) AS date,',
           '        max(result) AS result,',
           '        count(*) AS continuity_count',
           '      FROM (SELECT date,',
           '              result,',
           '              (SELECT max(date)',
           '               FROM results AS b',
           '               WHERE a.result <> b.result',
           '                 AND b.date < a.date) AS chokuzen_date',
           '               FROM results AS a) AS tempA',
           '      GROUP BY chokuzen_date) AS tempB',
           'GROUP BY result']

    self.find_by_sql(sql.join(' '))
  end
end