<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
Object action = request.getParameter("actionNo");
String actionNo = "";
if(action != null){
	actionNo = action.toString();
}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>用户管理</title>
	<style type="text/css">
		*{
			margin:0px;padding:0px;
		}
	</style>
  </head>
  <body>
  	<input type="hidden" name="errMsg" id="errMsg" value="${errMsg}"/>
	  <table style="width:100%;height:550px;">
		<tr>
			<td style="width:100%;height:100%;">
				<div style="overflow:hidden;width:100%;height:100%" >
					<iframe id="ifmReportContent" src="" frameborder="0" style="width:100%;height:100%" frameborder="0"></iframe>
					<script type="text/javascript">
					 	if(document.getElementById("errMsg").value.replace(/\s/g,'').length > 0){
					 		document.getElementById("ifmReportContent").setAttribute('src','error/404.jsp');
					 		alert(document.getElementById("errMsg").value);
					 	}else{
					 		if('<%=actionNo%>' == ''){
					 			document.getElementById("ifmReportContent").setAttribute('src','error/404.jsp');
					 			alert("打印报表请传入流水actionNo不能为空!");
					 		}else{
								document.getElementById("ifmReportContent").setAttribute('src','commAction!execute.action?actionNo=<%=actionNo%>&yxstate=' + Math.random());
					 		}
				 		}
					</script>
				</div>
			</td>
		</tr>
	</table>
  </body>
</html>
