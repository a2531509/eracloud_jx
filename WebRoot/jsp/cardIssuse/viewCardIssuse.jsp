<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<script type="text/javascript">
	var $viewgrid;
	$(function(){
		createSysCode({
			id:"agtCertType2",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		$viewgrid = createDataGrid({
			id:"dgview",
			url:"cardIssuse/cardIssuseAction!viewCardIssuse.action?taskId=${param.taskId}",
		    queryParams:{queryType:"0"},
			border:false,
			fit:true,
			fitColumns:true,
			border:false,
			scrollbarSize:0,
			singleSelect:true,
			columns:[[
				{field:'V_V',checkbox:true},
				{field:'MAKE_BATCH_ID',title:'批次号',sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:'TASK_ID',title:'任务编号',sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:'APPLY_ID',title:'申领编号',sortable:true,width : parseInt($(this).width() * 0.08)},
	            {field:'CUSTOMER_ID',title:'个人编号',sortable:true},
	            {field:'NAME',title:'客户姓名',sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:'CERT_NO',title:'证件号码',sortable:true,width : parseInt($(this).width() * 0.15)},
				{field:'APPLYSTATE',title:'申领状态',sortable:true,width : parseInt($(this).width() * 0.08),formatter:function(value,row,index){
					if(row["APPLY_STATE"] == "<%=com.erp.util.Constants.APPLY_STATE_YFF %>"){
						return "<span style=\"color:red;\">" + value + "</span>";
					}else{
						return value;
					}
				}},
				{field:'CARDTYPE',title:'卡类型',sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:'CARD_NO',title:'卡号',sortable:true,width : parseInt($(this).width() * 0.15)},
				{field:'IS_URGENT',title:'制卡方式',sortable:true,width : parseInt($(this).width() * 0.08)},
				{field:'APPLYTYPE',title:'申领类型',sortable:true,width : parseInt($(this).width() * 0.08)}
	        ]],toolbar:'#taskviewconts'
		});
	});
	
	function query(){
		$viewgrid.datagrid('load',{
			queryType:'0',
			"person.name":$("#name").val(),
			"person.certNo":$("#certNo").val(),
			"apply.applyId":$("#applyId").val()
		});
	}
	
	function tosavecustomerissuse(){
		 var rows = $viewgrid.datagrid("getChecked");
		 if(!rows){
			 $.messager.alert('系统消息','请勾选一条申领记录信息进行发放','info');
			 return;
		 }
		 var applyIds = "";
		 for(var d = 0;d < rows.length;d++){
			 if(rows[d].APPLY_STATE != "<%=com.erp.util.Constants.APPLY_STATE_YJS %>"){
				 $.messager.alert('系统消息','勾选的申领编号为' + rows[d].APPLY_ID + '申领记录信息不是【已接收】状态！','info');
				 return;
			 }
			applyIds = applyIds + rows[d].APPLY_ID + ',';
		 }
		 if(dealNull(applyIds).length <= 0){
			$.messager.alert('系统消息','请勾选一条申领记录进行发放','error');
			return;
		 }
		 applyIds = applyIds.substring(0,applyIds.length - 1);
		 $.messager.confirm('系统消息','您确定要发放勾选的申领记录吗？',function(r){
	   	 	if(r){
	   	 	$.messager.progress({text:'数据处理中，请稍后....'});
		   	 	var params = getformdata("agtinfo2");
	 			params["taskIds"]  = applyIds;
	 			params["issuseType"] = "1";
	 			params["rec.agtName"] = $("#agtName2").val();
				$.post("cardIssuse/cardIssuseAction!saveBatchCardIssuse.action",params,function(data,status){
					$.messager.progress("close");
	  		      	if(data.status == '0'){
	 		     		$.messager.alert('系统消息',data.errMsg,"info",function(){
		 		     		showReport("个人发放",data["dealNos"]);
		 		     		$viewgrid.datagrid("reload");
	 		     			$("#agtinfo2").form("reset");
	 		     		});
	 		     	}else if(data.sucNums <= 0){
		     			$.messager.alert("系统消息",data.errMsg,"error");
		     		}else{
		     			$.messager.alert("系统消息",data.errMsg,"info",function(){
			     			$grid.datagrid("reload");
			     			$("#agtinfo2").form("reset");
		     			});
		     		}
		 		},"json");
	   	 	}
	  	});
	}
	function readIdCard3(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#agtCertType2").combobox("setValue",'1');
		$("#agtCertNo2").val(certinfo["cert_No"]);
		$("#agtName2").val(certinfo["name"]);
	}
</script>
<n:layout>
<n:center layoutOptions="border:false">
	<div id="taskviewconts">
		<table class="tablegrid">
			<tr>
				<td class="tableleft" style="width:8%;">申领编号：</td>
				<td class="tableright" style="width:17%;"><input id="applyId" name="apply.applyId" type="text" class="textinput"/></td>
				<td class="tableleft" style="width:8%;">姓名：</td>
				<td class="tableright" style="width:17%;"><input id="name" name="person.name" type="text" class="textinput"/></td>
				<td class="tableleft" style="width:8%;">身份证号：</td>
				<td class="tableright" style="width:17%;"><input id="certNo" name="person.certNo" type="text" class="textinput"/></td>
				<td class="tableright">
					<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
					<shiro:hasPermission name="toOneCardIssuse">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save" plain="false" onclick="tosavecustomerissuse();">确定发放</a>
					</shiro:hasPermission>
				</td>
			</tr>
		</table>
	</div>
	<table id="dgview"></table>
</n:center>
<div data-options="region:'south',split:false,border:false" style="height:100px; width:auto;text-align:center;overflow:hidden;">
	<form id="agtinfo2" method="post" class="datagrid-toolbar" style="height:100%">
		<h3 class="subtitle">代理人信息</h3>
		<table class="tablegrid" style="width:100%">
			<tr>
				<th class="tableleft">代理人证件类型：</th>
				<td class="tableright"><input id="agtCertType2" name="rec.agtCertType" type="text" class="textinput"  value="1"/> </td>
				<th class="tableleft">代理人证件号码：</th>
				<td class="tableright"><input id="agtCertNo2" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox" validtype="idcard" maxlength="18"/></td>
				<th class="tableleft">代理人姓名：</th>
				<td class="tableright"><input id="agtName2" name="rec.agtName" type="text" class="textinput" maxlength="30"/></td>
				<th class="tableleft">代理人联系电话：</th>
				<td class="tableright"><input id="agtTelNo2" name="rec.agtTelNo" type="text" class="textinput easyui-validatebox" validtype="mobile" maxlength="11"/></td>
			</tr>
			<tr>
				<td class="tableleft" colspan="8">
					<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard3()">读身份证</a>
				</td>
			</tr>
		</table>
	</form>			
</div>
</n:layout>