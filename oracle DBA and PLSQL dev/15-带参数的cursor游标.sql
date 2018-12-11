declare
  lvc_unit varchar2(20 char);
  an_rownum number;
  cursor cur(i) is
    select a.unit_id
      from sample_unit a, etl_unit_level b
     where a.unit_id = b.unit_id
       and unit_level = i;

begin
  for i in 1 .. 7 loop
    for mycur in cur(i) loop
      lvc_unit := mycur.unit_id;
      begin
        begin
          -- Call the procedure
          cp_dw_loop(avc_schema  => 'J1_LDM',
                     avc_unit_id => lvc_unit,
                     avc_sswjg   => avc_sswjg,
                     avc_tjrq_q  => avc_tjrq_q,
                     avc_tjrq_z  => avc_tjrq_z,
                     avc_sjjgpd  => avc_sjjgpd,
                     an_rownum   => an_rownum);
        end;
      end loop;
    end loop;
  end;