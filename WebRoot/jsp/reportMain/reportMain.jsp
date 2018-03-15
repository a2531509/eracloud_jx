<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>用户管理</title>
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<style type="text/css">
		*{
			margin:0px;padding:0px;
		}
	</style>
	<script type="text/javascript">
	</script>
  </head>
  <body>
	  <table style="width:100%;height:550px;">
		<tr>
			<td style="width:100%;height:100%;">
				<div style="overflow:hidden;width:100%;height:100%" >
					<iframe id="ifmReportContent" src="" border="0" style="width:100%;height:100%" frameborder="0"></iframe>
					<script type="text/javascript">
						//避免缓存
						document.getElementById("ifmReportContent").setAttribute('src','commAction/commAction!showPDF.action?yxstate=' + Math.random());
					</script>
				</div>
			</td>
		</tr>
	</table>
  </body>
</html>
