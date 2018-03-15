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
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dg;
	var $temp;
	var $grid;
	var $querycerttype;
	$(function() {
		selectByType('agtCertType','CERT_TYPE');
	
	
		//制卡任务状态
		$("#taskState").combobox({
			width:174,
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=TASK_STATE",
			valueField:'codeValue',
			editable:false, //不可编辑状态
		    textField:'codeName',
		    panelHeight: 'auto',//自动高度适合
		    onSelect:function(node){
		 		$("#taskState").val(node.text);
		 	}
		});
	
		$dg = $("#dg");
		$grid=$dg.datagrid({
			url : "/cardapply/cardApplyAction!queryUndoOneCardApply.action",
			width : $(this).width() - 0.1,
			height : $(this).height() - 45,
			pagination:true,
			rownumbers:true,
			border:true,
			striped:true,
			fit:true,
			fitColumns: true,
			scrollbarSize:0,
			autoRowHeight:true,
			columns : [ [   {field:'APPLY_ID',title:'申领单号',sortable:true,checkbox:'ture'},
			            	{field:'APPLYNO',title:'申领编号',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'CERT_NO',title:'证件号码',sortable:true,width : parseInt($(this).width() * 0.15)},
							{field:'NAME',title:'客户姓名',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'APPLY_STATE',title:'申领状态',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'APPLY_WAY',title:'申领方式',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'APPLY_DATE',title:'申领时间',sortable:true,width : parseInt($(this).width() * 0.12)},
							{field:'CARD_TYPE',title:'卡类型',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'APPLY_BRCH_ID',title:'申领网点编号',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'APPLY_USER_ID',title:'申领柜员编号',sortable:true,width : parseInt($(this).width() * 0.08)}
							
			              ]],toolbar:'#tb',
			              onLoadSuccess:function(data){
			            	  $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
			            	  if(data.status != 0){
			            		 $.messager.alert('系统消息',data.errMsg,'error');
			            	  }
			              }
		});
	});

</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>零星申领</strong></span>的任务，且没有生成任务之前，可以进行申领撤销操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" >
				<table cellpadding="0" cellspacing="0"  style="width:100%" class="tablegrid">
					<tr>
                        <td align="right" class="tableleft" width="8%">证件号码：</td>
						<td align="left" class="tableright" width="15%"><input name="certNo"  class="textinput" id="certNo" maxlength="20" type="text"/></td>
						<td align="right" class="tableleft" width="8%">客户姓名：</td>
						<td align="left" class="tableright"  width="15%"><input name="clientName"  class="textinput" id="clientName" maxlength="20" type="text"/></td>
						<td align="right" class="tableleft" width="8%">申领日期始：</td>
						<td align="left" class="tableright" width="15%"><input id="beginTime" name="beginTime" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td align="right" class="tableleft" width="8%">申领日期止：</td>
						<td align="left" class="tableright"><input id="endTime" name="endTime" type="text"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
					</tr>
					<tr>
						<td align="right" class="tableleft" >网点编号：</td>
						<td align="left" class="tableright"><input id="brch_Id" name="brch_Id" type="text" class="textinput" maxlength="20" /></td>
						<td align="right" class="tableleft" >申领编号：</td>
						<td align="left" class="tableright" ><input id="apply_Id" name="apply_Id" type="text" class="textinput" maxlength="20"/></td>
						<td align="left" colspan="4">
					      <a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="undoOneCardApplySave">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-back"  plain="false" onclick="toSaveInfo();">申领撤销</a>
							</shiro:hasPermission>
						</td>
					</tr>
				
				</table>
			</div>
	  		<table id="dg" title="已申领信息信息"></table>
	  </div>
  </body>
</html>
<script type="text/javascript">
function query(){
	 $dg.datagrid('load',{
		    queryType:"0",
			certNo:$("#certNo").val(),
			clientName:$("#clientName").val(),
			beginTime:$("#beginTime").val(),
			endTime:$("#endTime").val(),
			brch_Id:$("#brch_Id").val(),
			apply_Id:$("#apply_Id").val()
		});
}

//撤销
function toSaveInfo(){
	 var rows = $dg.datagrid('getChecked');
	 if(rows.length==1){
		 //组转勾选的参数
		 $.messager.confirm('系统消息','你真的确定申领撤销保存吗？', function(r){
     		if (r){
  				 $.post("/cardapply/cardApplyAction!saveUndoCardApply.action", {apply_Id:rows[0].APPLY_ID},
				   function(data){
				     	if(data.status == '0'){
				     		$.messager.alert('系统消息','申领撤销保存成功','info',function(){
				     			showReport("个人卡片申领撤销",data.dealNo,function(){
									window.history.go(0);
								});
				     			$dg.datagrid('reload');
				     		});
				     	}else{
				     		$.messager.alert('系统消息',data.errMsg,'error');
				     	}
				   }, "json");
     			}
     		});
	 }else{
		 $.messager.alert('系统消息','请选择一条记录进行操作','info');
		 return;
	 }
 }
function readIdCard(){
	var certinfo = getcertinfo();
	if(dealNull(certinfo["name"]) == ""){
		return;
	}else{
		$("#certNo").val(certinfo["cert_No"]);
	}
}
</script>