// @generated automatically by Diesel CLI.

diesel::table! {
    leg_breaks (run_id, phase_number, leg_position_id) {
        run_id -> Nullable<Integer>,
        phase_number -> Nullable<Integer>,
        break_time -> Nullable<Integer>,
        break_order -> Nullable<Integer>,
        leg_position_id -> Nullable<Integer>,
    }
}

diesel::table! {
    leg_position (id) {
        id -> Nullable<Integer>,
        name -> Text,
    }
}

diesel::table! {
    phases (run_id, phase_number) {
        run_id -> Nullable<Integer>,
        phase_number -> Nullable<Integer>,
        phase_time -> Nullable<Float>,
        shield_time -> Nullable<Float>,
        leg_time -> Nullable<Float>,
        body_kill_time -> Nullable<Float>,
        pylon_time -> Nullable<Float>,
    }
}

diesel::table! {
    player_pb (pb_run_id) {
        pb_run_id -> Nullable<Integer>,
        pb_total_time -> Nullable<Float>,
        pb_total_flight_time -> Nullable<Float>,
        pb_total_shield_time -> Nullable<Float>,
        pb_total_leg_time -> Nullable<Float>,
        pb_total_body_time -> Nullable<Float>,
        pb_total_pylon_time -> Nullable<Float>,
    }
}

diesel::table! {
    runs (id) {
        id -> Nullable<Integer>,
        time_stamp -> Timestamp,
        run_name -> Nullable<Text>,
        player_name -> Nullable<Text>,
        bugged_run -> Nullable<Bool>,
        aborted_run -> Nullable<Bool>,
        solo_run -> Nullable<Bool>,
        total_time -> Nullable<Float>,
        total_flight_time -> Nullable<Float>,
        total_shield_time -> Nullable<Float>,
        total_leg_time -> Nullable<Float>,
        total_body_time -> Nullable<Float>,
        total_pylon_time -> Nullable<Float>,
    }
}

diesel::table! {
    shield_changes (id) {
        id -> Nullable<Integer>,
        shield_time -> Nullable<Integer>,
        status_effect_id -> Nullable<Integer>,
        run_id -> Nullable<Integer>,
        phase_number -> Nullable<Integer>,
    }
}

diesel::table! {
    squad_members (run_id, member_name) {
        run_id -> Nullable<Integer>,
        member_name -> Nullable<Text>,
    }
}

diesel::table! {
    status_effects (id) {
        id -> Nullable<Integer>,
        name -> Text,
    }
}

diesel::joinable!(leg_breaks -> leg_position (leg_position_id));
diesel::joinable!(phases -> runs (run_id));
diesel::joinable!(player_pb -> runs (pb_run_id));
diesel::joinable!(shield_changes -> status_effects (status_effect_id));
diesel::joinable!(squad_members -> runs (run_id));

diesel::allow_tables_to_appear_in_same_query!(
    leg_breaks,
    leg_position,
    phases,
    player_pb,
    runs,
    shield_changes,
    squad_members,
    status_effects,
);
