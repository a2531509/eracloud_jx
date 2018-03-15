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
    <title>对账文件处理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include> 
	<script type="text/javascript">
	
	    $(function(){
	    	//文件类型
	    	$("#fileType").combobox({
	    		width:174,
	    		valueField:'codeValue',
	    		editable:false,
	    		value:"",
	    	    textField:"codeName",
	    	    panelHeight:'auto',
	    	    data:[{codeValue:'',codeName:"请选择"},{codeValue:'CZ',codeName:"充值文件"},
	    	          {codeValue:'XF',codeName:"消费文件"},{codeValue:'QT',codeName:"圈提文件"},{codeValue:'QF',codeName:"圈付文件"}]
	    	});
	    	
	    	
	    });
		function getcheckfile(){
			$.messager.confirm('确认对话框', '您确定要获取对账文件？', function(r){
				if (r){
					if(dealNull($("#coOrgId").val()) == ""){
						$.messager.alert("系统消息","请输入合作机构编号！","error",function(){
							$("#coOrgId").focus();
						});
						return;
					}
					if(dealNull($("#checkDate").val()) == ""){
						$.messager.alert("系统消息","请输入要获取的对账日期！","error",function(){
							$("#checkDate").focus();
						});
						return;
					}
					if(dealNull($("#fileType").combobox("getValue")) == ""){
						$.messager.alert("系统消息","请选择对账文件类型！","error",function(){
							$("#fileType").combobox("showPanel");
						});
						return;
					}
					$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
					$.post("corpCheckAccount/corpCheckAccountAction!getCheckFile.action",
							{coOrgId:$("#coOrgId").val(),checkDate:$("#checkDate").val(),fileType:$("#fileType").combobox("getValue")},
							function(result){
								$.messager.progress('close');
								if(result.status =='1'){
									$.messager.alert('系统消息',result.errMsg,'error');
								}else{
									$.messager.alert('系统消息',result.errMsg,'info');
								}
							},'json');
				}
			});
		}
		
		function autoCom(){
			if($("#coOrgId").val() == ""){
				$("#coOrgName").val("");
			}
			$("#coOrgId").autocomplete({
				position: {my:"left top",at:"left bottom",of:"#coOrgId"},
			    source: function(request,response){
				    $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgId":$("#coOrgId").val(),"queryType":"1","initCorpType":"2"},function(data){
				    	response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
				    },'json');
			    },
			    select: function(event,ui){
			      	$('#coOrgId').val(ui.item.label);
			        $('#coOrgName').val(ui.item.value);
			        return false;
			    },
		      	focus:function(event,ui){
			        return false;
		      	}
		    }); 
		}
		function autoComByName(){
			if($("#coOrgName").val() == ""){
				$("#coOrgId").val("");
			}
			$("#coOrgName").autocomplete({
			    source:function(request,response){
			        $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgName":$("#coOrgName").val(),"queryType":"0","initCorpType":"2"},function(data){
			            response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
			        },'json');
			    },
			    select: function(event,ui){
			    	$('#coOrgId').val(ui.item.value);
			        $('#coOrgName').val(ui.item.label);
			        return false;
			    },
			    focus: function(event,ui){
			        return false;
			    }
		    }); 
		}
	</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>合作机构指定日期的对账文件，获取对账文件后可以在《合作机构对账》</strong></span>下查询结果!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true,fit:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;background-color:rgb(245,245,245);">
			<div id="tb" style="padding:20px 80px 20px;" class="easyui-panel datagrid-toolbar" data-options="fit:true">
				<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft" style="width:10%">合作机构编号：</td>
						<td class="tableright" style="width:13%"><input type="text" name="coOrgId" id="coOrgId" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td class="tableleft" style="width:10%">合作机构名称：</td>
						<td class="tableright" style="width:13%"><input type="text" name="coOrgName" id="coOrgName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td class="tableleft" style="width:8%">文件类型：</td>
						<td class="tableright" style="width:13%"><input type="text" name="fileType" id="fileType" class="textinput" /></td>
						<td class="tableleft" style="width:8%">对账日期：</td>
						<td class="tableright" style="width:13%">
							<input id="checkDate" type="text" name="checkDate"  class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyyMMdd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						<td class="tableright" style="width:14%">
							<shiro:hasPermission name="checkfileimp">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import"  plain="false" onclick="getcheckfile();">下载对账文件</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  </div>
  </body>
</html>