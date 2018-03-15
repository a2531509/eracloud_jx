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
<title>个人申领</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript" src="js/jquery-ui.js"></script>
<style>
	.tablegrid th{font-weight:700};
</style>
<script type="text/javascript">
var isFirstLoad = true;
var $dg;
var $temp;
var $grid;
$(function(){
	isFirstLoad = true;
	if("${defaultErrorMasg}" != ''){
		$.messager.alert("系统消息","${defaultErrorMasg}","error");
	}
	 $dg = $("#dg");
	 $.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			//minLength:"1"
		});
	 $grid=$dg.datagrid({
		url : "/zxcApp/ZxcAppAction!queryZxc.action",
		pagination:false,
		border:false,
		striped:true,
		fit:true,
		toolbar:'#tb',
		fitColumns:true,
		singleSelect:false,
		pageSize:5,
	  	columns:[[
	  		{field:'CUSTOMER_ID',title:'个人编号',sortable:true,checkbox:'ture'},
            {field:'NAME',title:'客户姓名',sortable:true,width : parseInt($(this).width() * 0.1)},
			{field:'CERT_NO',title:'证件号码',sortable:true,width : parseInt($(this).width() * 0.15)},
			{field:'CARD_TYPE',title:'卡类型',sortable:true,width : parseInt($(this).width() * 0.1)},
			{field:'CARD_NO',title:'卡号',sortable:true,width : parseInt($(this).width() * 0.2)},
			{field:'CARD_STATE',title:'卡状态',sortable:true,width:parseInt($(this).width() * 0.1)},
			{field:'APP_NAME',title:'应用名称',sortable:true,width:parseInt($(this).width() * 0.1)},
			{field:'BIND_STATE',title:'最后交易状态',sortable:true,width:parseInt($(this).width() * 0.1)},
			{field:'USER_ID',title:'操作员编号',sortable:true,width:parseInt($(this).width() * 0.1)}
         ]],toolbar:'#tb',
         onLoadSuccess:function(data){
	       	 $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
	       	 if(data.status != 0){
	       		 $.messager.alert('系统消息',data.errMsg,'error');
	       	 }else{
	       		  $("#certNo2").val(data.certNo);
	       		  $("#gender2").val(data.gender);
	       		  $("#mobileNo").val(data.mobileNo);
	       		  $("#costFee").combobox({panelHeight:'auto',valueField: 'label',textField: 'value',value:data.costFee,data: [{label: data.costFee,value: data.costFee}]} );
	       		  $("#customerId2").val(data.customerId);
	       		  $("#name2").val(data.name);
	       	  }
      	}
	});
});
function readCard(){
	$.messager.progress({text:'正在获取卡信息，请稍后....'});
	cardmsg = getcardinfo();
	if(dealNull(cardmsg["card_No"]).length == 0){
		$.messager.progress('close');
		$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
		return;
	}
	$.messager.progress('close');
	$('#cardNo').val(cardmsg["card_No"]);
	isreadcard = 0;
	curreadcardno = cardmsg["card_No"];
	queryinfo();
}
//新增或是编辑保存
function toSaveInfo(){
	var certNo2=$('#certNo2').val();
	if(dealNull(certNo2) == ''){
		$.messager.alert('系统消息','证件号码不能为空,请先查询再进行开通保存！','error');
		return;
	}
	     $.messager.confirm("系统消息","您确定要确认开通应用吗？",function(r){
		 if(r){
				$.messager.progress({text:'数据处理中，请稍后....'});
				$.ajax({
					url:"/zxcApp/ZxcAppAction!saveZxcOpen.action",
					data:{ 
					    costFees:$('#costFee').combobox('getValue'),
					    customerId:$('#customerId2').val(),
					    customerId:$('#customerId2').val(),
					    cancle_reason:$('#cancle_reason').val(),
					    mobileNo:$('#mobileNo').val()
					  },
					success: function(rsp){
						$.messager.progress('close');
						rsp = $.parseJSON(rsp);
						$.messager.alert('系统消息',rsp.message,(rsp.status ? 'info':'error'),function(){
							if(rsp.status){
								showReport('报表信息',rsp.dealNo);
								$("#dg").datagrid('reload');
							}
						});
					},
					error:function(){
						$.messager.progress('close');
						$.messager.alert("系统消息","挂失卡片发生错误：请求失败，请重试！","error");
					}
				});
			}
			});
}
//新增或是编辑保存
function toSaveBack(){
	var certNo2=$('#certNo2').val();
	if(dealNull(certNo2) == ''){
		$.messager.alert('系统消息','证件号码不能为空,请先查询再进行开通保存！','error');
		return;
	}

	$.messager.confirm("系统消息","您确定要确认开通应用吗？",function(r){
		 if(r){
			 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			 $.post("/zxcApp/ZxcAppAction!saveZxcOpen.action", 
				{ 
				    costFees:$('#costFee').combobox('getValue'),
				    customerId:$('#customerId2').val(),
				    cancle_reason:$('#cancle_reason').val(),
				    mobileNo:$('#mobileNo').val()

				  },
				 function(data){
					 $.messager.progress('close');
			     	if(data.status == '0'){
			     		$.messager.alert('系统消息','保存成功','info',function(){
			     			$dg.datagrid('reload');
			     		});
			     	}else{
			     		$.messager.alert('系统消息',data.msg,'error');
			     	}
			 },"json");
		 }
	});
}
function queryinfo(){
	var certNo=$('#certNo').val();
	var cardNo=$('#cardNo').val();
	if(dealNull(certNo) == ''&& dealNull(cardNo) == ''){
		$.messager.alert('系统消息','证件号码和卡号不能同时为空','error');
		return;
	}
   $dg.datagrid('load',{
	    queryType:'0',
		certNo:$("#certNo").val(),
		cardNo:$("#cardNo").val()
	});
}
function readIdCard(){
	var certinfo = getcertinfo();
	$("#certNo").val(certinfo["cert_No"]);
	queryinfo();
}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>自行车的应用开通与取消操作操作，特别提醒：'开通成功'收取相应的押金，'取消该应用'退还押金给市民。</strong></span></span>
		</div>
     </div>
	<div data-options="region:'center',border:true" style="border-left:none;width:100%";overflow:hidden;padding:0px;height:20%;" >
		<div id="tb" style="padding:2px 0,width:100%">
			<table  id="tb" cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
				<tr >
					<td class="tableleft" style="width:6%">证件号码：</td>
					<td class="tableright" style="width:20%"><input name="certNo"  class="textinput" id="certNo" type="text"/></td>
					<td class="tableleft" style="width:6%">卡号：</td>
					<td class="tableright" style="width:20%"><input name="cardNo"  class="textinput" id="cardNo" type="text" maxlength="20"/></td>
					<td class="tableright">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="queryinfo()">查询</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="自行车开通信息" style="width:100%"></table>
  	</div>
  	<div data-options="region:'south',border:false" style="height:60%;" class="datagrid-toolbar" >
        <h3 class="subtitle">自行车应用开通与取消维护</h3>
	     <form id="form" method="post" >
	            <input name="customerId2" id="customerId2"  type="hidden" value="${customerId}" />
				<table class="tablegrid" width="100%">
					 <tr>
					    <th class="tableleft" style="width:10%">姓名：</th>
						<td class="tableright" style="width:19%"><input name="name2" id="name2" class="textinput" disabled="true" style="background: #EFEFEF;" type="text" required="required" /></td>
						<th class="tableleft" style="width:10%">证件号码：</th>
						<td class="tableright" style="width:19%"><input name="certNo2"  class="textinput" id="certNo2" disabled="true" type="text" validtype="idcard"  style="background: #EFEFEF;" required="required" /></td>
					 	<th class="tableleft">性别：</th>
						<td class="tableright"><input name="gender2" id="gender2" type="text" class="textinput" style="background: #EFEFEF;" disabled="true"/></td>
					 </tr>
		
		
			
					<tr>
					    <th class="tableleft">手机号码：</th>
						<td class="tableright"><input name ="mobileNo" id="mobileNo"  type="text" class="textinput"/></td> 
					    <th class="tableleft">押金：</th>
					    <td class="tableright" ><input name="costFee" class="textinput" id="costFee" type="text"/>   </td>
						<th class="tableleft">原因：</th>
						<td class="tableright" ><input name="cancle_reason" class="textinput" id="cancle_reason" maxlength="20" type="text"/></td>
						<td>&nbsp;</td>
					</tr>
			
				     <tr>
						<td colspan="7" align="center" class="tableQueryButton">
							<shiro:hasPermission name="saveOpen">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="toSaveInfo();">开通保存</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="saveCancel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-back"  plain="false" onclick="toSaveBack();">应用取消</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
	</div>
  </body>
</html>
