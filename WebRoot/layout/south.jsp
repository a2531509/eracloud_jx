<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<div style="margin-left:0px;margin-top:0px;overflow:hidden;" class="datagrid-toolbar">
	<table style="margin:0px;padding:0px;border:none;width:100%;overflow:hidden;">
		<tr>
			<td align="left"><span id="systime" style="background-image:url(images/time.png);background-repeat:no-repeat;padding-left:18px;background-position:left center;line-height:150%;"></span></td>
			<td align="right"><span>版权所有&nbsp;©2015 - 2115 &nbsp;&nbsp;All Rights Reserved</span></td>
		</tr>
	</table>
</div>
<script type="text/javascript">
//系统时间设置
function showTime(){
	var str = "systime";
    var now = new Date();
    var dayarray = new Array("星期日","星期一","星期二","星期三","星期四","星期五","星期六");
    var dtstr = " " + now.getFullYear()+"年";
    var month = now.getMonth()+1;
    if (month <= 9){
        dtstr = dtstr + "0" + month + "月";
    }else{
        dtstr = dtstr + month + "月 ";
    }
    var day = now.getDate();
    if (day <= 9){
        dtstr = dtstr + "0" + day+ "日";
    }else{
        dtstr = dtstr + day+ "日";
    }
    dtstr = dtstr + " " + dayarray[now.getDay()] + " ";
    var hours=now.getHours()
    if (hours <= 9){
        dtstr = dtstr + "0" + hours +"<b>:</b>";
    }else{
        dtstr = dtstr + hours +"<b>:</b>";
    }
    var minutes = now.getMinutes()
    if (minutes <= 9){
        dtstr = dtstr + "0" + minutes +"<b>:</b>";
    }else{
        dtstr = dtstr + minutes +"<b>:</b>";
    }
    var seconds = now.getSeconds()
    if (seconds <= 9){
        dtstr = dtstr + "0" + seconds;
    }else{
        dtstr = dtstr + seconds;
    }
    $('#systime').html(dtstr);
    setTimeout("showTime()",1000);
}
showTime();
</script>
