CLASS zcl_event_util_303 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      tt_header TYPE STANDARD TABLE OF zcit_event_303 WITH EMPTY KEY,
      tt_item   TYPE STANDARD TABLE OF zcit_party_303 WITH EMPTY KEY,

      tt_event_delete TYPE STANDARD TABLE OF zcit_event_303-event_id WITH EMPTY KEY,
      tt_part_delete  TYPE STANDARD TABLE OF zcit_party_303-part_id  WITH EMPTY KEY.

    CLASS-DATA:
      gt_header_buffer TYPE tt_header,
      gt_item_buffer   TYPE tt_item,
      gt_header_delete TYPE tt_event_delete,
      gt_item_delete   TYPE tt_part_delete.

    CLASS-METHODS:
      buffer_event_data
        IMPORTING it_header TYPE tt_header,

      buffer_item_data
        IMPORTING it_item TYPE tt_item,

      buffer_event_delete
        IMPORTING iv_event_id TYPE zcit_event_303-event_id,

      buffer_item_delete
        IMPORTING iv_part_id TYPE zcit_party_303-part_id,

      save_to_db,

      clear_buffers.

ENDCLASS.



CLASS zcl_event_util_303 IMPLEMENTATION.

  METHOD buffer_event_data.

    LOOP AT it_header INTO DATA(ls_header).

      READ TABLE gt_header_buffer
        ASSIGNING FIELD-SYMBOL(<fs_header>)
        WITH KEY event_id = ls_header-event_id.

      IF sy-subrc = 0.

        <fs_header> = CORRESPONDING #(
                        BASE ( <fs_header> )
                        ls_header ).

      ELSE.

        APPEND ls_header TO gt_header_buffer.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.



  METHOD buffer_item_data.

    LOOP AT it_item INTO DATA(ls_item).

      READ TABLE gt_item_buffer
        ASSIGNING FIELD-SYMBOL(<fs_item>)
        WITH KEY event_id = ls_item-event_id
                 part_id  = ls_item-part_id.

      IF sy-subrc = 0.

        <fs_item> = CORRESPONDING #(
                      BASE ( <fs_item> )
                      ls_item ).

      ELSE.

        APPEND ls_item TO gt_item_buffer.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.



  METHOD buffer_event_delete.

    CHECK iv_event_id IS NOT INITIAL.

    APPEND iv_event_id TO gt_header_delete.

  ENDMETHOD.



  METHOD buffer_item_delete.

    CHECK iv_part_id IS NOT INITIAL.

    APPEND iv_part_id TO gt_item_delete.

  ENDMETHOD.



  METHOD save_to_db.

    "=========================================
    " 1. DELETE EVENT + CHILD RECORDS
    "=========================================
    LOOP AT gt_header_delete INTO DATA(lv_event_id).

      DELETE FROM zcit_party_303
        WHERE event_id = @lv_event_id.

      DELETE FROM zcit_event_303
        WHERE event_id = @lv_event_id.

    ENDLOOP.


    "=========================================
    " 2. DELETE SINGLE PARTICIPANTS
    "=========================================
    LOOP AT gt_item_delete INTO DATA(lv_part_id).

      DELETE FROM zcit_party_303
        WHERE part_id = @lv_part_id.

    ENDLOOP.


    "=========================================
    " 3. SAVE HEADER (CREATE / UPDATE)
    "=========================================
    IF gt_header_buffer IS NOT INITIAL.

      MODIFY zcit_event_303
        FROM TABLE @gt_header_buffer.

    ENDIF.


    "=========================================
    " 4. SAVE ITEM (CREATE / UPDATE)
    "=========================================
    IF gt_item_buffer IS NOT INITIAL.

      MODIFY zcit_party_303
        FROM TABLE @gt_item_buffer.

    ENDIF.


    "=========================================
    " 5. CLEAR BUFFERS
    "=========================================
    clear_buffers( ).

  ENDMETHOD.



  METHOD clear_buffers.

    CLEAR:
      gt_header_buffer,
      gt_item_buffer,
      gt_header_delete,
      gt_item_delete.

  ENDMETHOD.

ENDCLASS.
