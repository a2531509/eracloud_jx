<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE html>
<html>
<head>
<base href="<%=basePath%>">
</head>
<body>
	<%
		double d = Math.random() * 10 + 1;
		int i = (int) d;
		String n = String.valueOf(i);
		if (i < 10) {
			n = "0" + n;
		}
	%>
	<img alt="" src="data/dogs/puppy_dogs_<%=n%>.png">
</body>
</html>
