CLASS lhc_Event DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations
      FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations
      FOR Event
      RESULT result.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations
      FOR Event
      RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Event.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Event.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Event.

    METHODS read FOR READ
      IMPORTING keys FOR READ Event
      RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Event.

    METHODS rba_Participants FOR READ
      IMPORTING keys_rba FOR READ Event\_Participants FULL result_requested
      RESULT result
      LINK association_links.

    METHODS cba_Participants FOR MODIFY
      IMPORTING entities_cba FOR CREATE Event\_Participants.

ENDCLASS.



CLASS lhc_Event IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD create.

    DATA lt_header TYPE zcl_event_util_303=>tt_header.
    GET TIME STAMP FIELD DATA(lv_ts).

    lt_header = CORRESPONDING #( entities MAPPING FROM ENTITY ).

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).

      IF <ls_header>-event_id IS INITIAL.
        TRY.
            <ls_header>-event_id =
              cl_system_uuid=>create_uuid_c32_static( ).
          CATCH cx_uuid_error.
        ENDTRY.
      ENDIF.

      <ls_header>-localcreatedat     = lv_ts.
      <ls_header>-localcreatedby     = sy-uname.
      <ls_header>-locallastchangedat = lv_ts.
      <ls_header>-locallastchangedby = sy-uname.
      <ls_header>-lastchangedat      = lv_ts.

    ENDLOOP.

    zcl_event_util_303=>buffer_event_data( lt_header ).

    mapped-event =
      VALUE #(
        FOR i = 1 UNTIL i > lines( lt_header )
        (
          %cid    = entities[ i ]-%cid
          EventId = lt_header[ i ]-event_id
        )
      ).

  ENDMETHOD.



  METHOD update.

    DATA lt_header TYPE zcl_event_util_303=>tt_header.
    GET TIME STAMP FIELD DATA(lv_ts).

    lt_header = CORRESPONDING #( entities MAPPING FROM ENTITY ).

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).

      <ls_header>-locallastchangedat = lv_ts.
      <ls_header>-locallastchangedby = sy-uname.
      <ls_header>-lastchangedat      = lv_ts.

    ENDLOOP.

    zcl_event_util_303=>buffer_event_data( lt_header ).

  ENDMETHOD.



  METHOD delete.

    LOOP AT keys INTO DATA(ls_key).

      zcl_event_util_303=>buffer_event_delete(
        iv_event_id = ls_key-EventId ).

    ENDLOOP.

  ENDMETHOD.



  METHOD read.

    CHECK keys IS NOT INITIAL.

    SELECT *
      FROM zcit_event_303
      FOR ALL ENTRIES IN @keys
      WHERE event_id = @keys-EventId
      INTO CORRESPONDING FIELDS OF TABLE @result.

  ENDMETHOD.



  METHOD lock.

    DATA(lo_lock) =
      cl_abap_lock_object_factory=>get_instance(
        iv_name = 'EZCIT_EVENT_303' ).

    LOOP AT keys INTO DATA(ls_key).

      TRY.
          lo_lock->enqueue(
            it_parameter = VALUE #(
              (
                name  = 'EVENT_ID'
                value = REF #( ls_key-EventId )
              )
            ) ).

        CATCH cx_abap_foreign_lock
              cx_abap_lock_failure.

          APPEND VALUE #(
            EventId = ls_key-EventId
          ) TO failed-event.

      ENDTRY.

    ENDLOOP.

  ENDMETHOD.



  METHOD cba_Participants.

    DATA lt_item TYPE zcl_event_util_303=>tt_item.

    LOOP AT entities_cba INTO DATA(ls_cba).

      DATA(lt_target) =
        CORRESPONDING zcl_event_util_303=>tt_item(
          ls_cba-%target MAPPING FROM ENTITY ).

      LOOP AT lt_target ASSIGNING FIELD-SYMBOL(<ls_item>).

        <ls_item>-event_id = ls_cba-EventId.

        IF <ls_item>-part_id IS INITIAL.
          TRY.
              <ls_item>-part_id =
                cl_system_uuid=>create_uuid_c22_static( ).
            CATCH cx_uuid_error.
          ENDTRY.
        ENDIF.

      ENDLOOP.

      APPEND LINES OF lt_target TO lt_item.

    ENDLOOP.

    zcl_event_util_303=>buffer_item_data( lt_item ).

  ENDMETHOD.



  METHOD rba_Participants.

    CHECK keys_rba IS NOT INITIAL.

    SELECT *
      FROM zcit_party_303
      FOR ALL ENTRIES IN @keys_rba
      WHERE event_id = @keys_rba-EventId
      INTO TABLE @DATA(lt_items).

    result = CORRESPONDING #( lt_items MAPPING TO ENTITY ).

  ENDMETHOD.

ENDCLASS.
