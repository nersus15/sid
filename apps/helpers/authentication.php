<?php

use Firebase\JWT\JWT;

function is_login($role = null, $user = null, $jwt = null)
{
    /** @var qbuilder $db */
    $db = new qbuilder();

    $gunakanJWT = JWT_AUTH;

    if(!empty($jwt))
        $gunakanJWT = $jwt;

    if (!$gunakanJWT)
        $userdata = sessiondata('login'); //sessiondata('login')
    else {
        $token = isset($_POST['_token']) ? $_POST['_token'] : null;
        list($isLogin, $data) = verfify_token($token);
    }
    if (!empty($userdata) && SYNC_DATAUSER) {
        $db->select('users.username, anggota.*');
        $db->where('username', $userdata['username']);
        $db->from('users');
        $db->join('anggota', 'users.anggota = anggota.id');
        $u = $db->results();

        if (count($u) > 1 || empty($u))
            return false;
        else
            set_userdata('login', $u[0]);

        $userdata = get_userdata('login');
    }

    if (empty($role) && empty($user)) {
        if ($gunakanJWT)
            return $isLogin;
        else
            return !empty($userdata);
    } elseif (!empty($userdata) && !empty($role) && empty($user)) {
        if ($gunakanJWT)
            return $data['role'] == $role;
        elseif (!$gunakanJWT && $role == 'bendahara')
            return $userdata['role'] == 'bendahara 1' || $userdata['role'] == 'bendahara 2';
        elseif (!$gunakanJWT && $role == 'admin')
            return $userdata['role'] == 'ketua yayasan' || $userdata['role'] == 'kepala sekolah';
        elseif (!$gunakanJWT && $role != 'bendahara')
            return $userdata['role'] == $role;
    } elseif (!empty($userdata) && empty($role) && !empty($user)) {
        if ($gunakanJWT)
            $data['username'] == $user;
        else
            return $userdata['username'] == $user;
    } elseif (!empty($userdata) && !empty($role) && !empty($user)) {
        if ($gunakanJWT)
            return $data['username'] == $user && $data['role'] == $role;
        else
            return $userdata['username'] == $user && $userdata['role'] == $role;
    }
}

function loginTryCount(){
    
}

function verify_token($token){
    
}

function token_register_checker($token)
{
    if (empty($token))
        return['message' => 'Token kosong', 'type' => false];

    $db = new qbuilder();

    $db->select('*');
    $db->from('token_registrasi');
    $db->where('id', $token);
    $results = $db->results();
    if (empty($results))
        return['message' => 'Token registrasi yang anda masukkan tidak terdaftar', 'type' => false];
    if (count($results) > 1)
        return['message' => 'Token registrasi yang anda masukkan tidak valid', 'type' => false];

    $results = $results[0];
    if (strtotime($results['expired']) < time())
        return['message' => 'Token registrasi yang anda masukkan sudah expired', 'type' => false];
    
    return ['message' => null, 'type' => true];
}
