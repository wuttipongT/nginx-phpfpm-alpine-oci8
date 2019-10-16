
<?php  
print '<h1>PHP Version 7.3.10</h1>';
print "<h2>OCI8</h2>";
$conn_str="(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.136.128)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = orcl)))";
$user="user01";
$pwd="secert";

$conn = oci_connect($user, $pwd, $conn_str, 'AL32UTF8') or die('Connect Error');
$sql_text = "select * from all_users where rownum <=2";
$stid = oci_parse($conn, $sql_text);
$r = oci_execute($stid);
$nrow = oci_fetch_all($stid, $result, 0, -1, OCI_FETCHSTATEMENT_BY_ROW);
print '<pre>';
print_r($result);
print '</pre>';

print '<h2>PDO OCI</h2>';
try {
$conn = new PDO("oci:dbname=".$conn_str, $user, $pwd);
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$stmt = $conn->prepare($sql_text);
$stmt->execute();
$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
print '<pre>';
print_r($result);
print '</pre>';
} catch(PDOException $e) {
    echo 'ERROR: ' . $e->getMessage();
}
?>
