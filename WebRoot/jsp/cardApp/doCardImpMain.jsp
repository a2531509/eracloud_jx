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
<title>任务导出银行</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dg;
	var $temp;
	var $grid;
	var $querycerttype;
	$(function(){
		 $('#bankId').combobox({
            valueField: 'bankId', 
            textField: 'bankName',
            //注册事件
            onChange: function (newValue, oldValue) {
                if(newValue != null){
                     var thisKey = encodeURIComponent($('#bankId').combobox('getText')); //搜索词
                     var urlStr = "/madeCardTask/madeCardTaskAction!getBankName.action?objStr=" + thisKey;
                     var v = $("#bankId").combobox("reload", urlStr);
                }
            }
	    });
		//获取银行编号
		 $('#bankIdimp').combobox({
            valueField: 'bankId', 
            textField: 'bankName',
            //注册事件
            onChange: function (newValue, oldValue) {
                if (newValue != null) {
                    var thisKey = encodeURIComponent($('#bankIdimp').combobox('getText')); //搜索词
                    var urlStr = "/madeCardTask/madeCardTaskAction!getBankName.action?objStr=" + thisKey;
                    var v = $("#bankIdimp").combobox("reload", urlStr);
                }
            }
	    });
		//制卡任务状态
		createSysCode({id:"taskState",codeType:"TASK_STATE"});
		//构造城区下拉框
		createRegionSelect(
			{id:"regionId"},
			{id:"townId"},
			{id:"commId"}
		);
		//查询条件卡类型
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE"
		});
		$dg = $("#dg");
		$grid=$dg.datagrid({
			url : "madeCardTask/madeCardTaskAction!cardTaskQuery.action",
			width : $(this).width() - 0.1,
			height : $(this).height() - 45,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			fitColumns: true,
			scrollbarSize:0,
			autoRowHeight:true,
			//0未启用1正常2口头挂失3书面挂失9注销
			columns : [ [   {field:'SETTLEID',title:'id',sortable:true,checkbox:'ture'},
							{field:'TASK_ID',title:'任务编号',sortable:true,width : parseInt($(this).width() * 0.12)},
							{field:'MAKE_BATCH_ID',title:'批次号',sortable:true,width : parseInt($(this).width() * 0.1)},
							{field:'TASK_STATE',title:'任务状态',sortable:true,width : parseInt($(this).width() * 0.1)},
							{field:'TASK_WAY',title:'任务组织方式',sortable:true,width : parseInt($(this).width() * 0.1)},
							{field:'TASK_NAME',title:'任务名称',sortable:true,width : parseInt($(this).width() * 0.2)},
							{field:'TASK_DATE',title:'任务时间',sortable:true,width : parseInt($(this).width() * 0.1)},
							{field:'CARD_TYPE',title:'卡类型',sortable:true,width : parseInt($(this).width() * 0.1)},
							{field:'IS_URGENT',title:'制卡方式',sortable:true,width : parseInt($(this).width() * 0.1)},
							{field:'TASK_SUM',title:'任务数量',sortable:true,width : parseInt($(this).width() * 0.05)}
			              ]],toolbar:'#tb',
			              onLoadSuccess:function(data){
			            	  $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
			            	  if(data.status != 0){
			            		 $.messager.alert('系统消息',data.errMsg,'error');
			            	  }
			              }
		});
	});
		
	function query(){
		$dg.datagrid('load',{
			queryType:'0',//查询类型
			madeCardBatchNo:$("#madeCardBatchNo").val(),
			madeCardTaskNo:$("#madeCardTaskNo").val(),
			taskState:$("#taskState").combobox('getValue'),
			corpId:$("#corpId").combobox('getValue'),
			cardType:$("#cardType").combobox('getValue'),
			taskStartDate:$("#taskStartDate").val(),
			taskEndDate:$("#taskEndDate").val(),
			regionId:$("#regionId").combobox('getValue'),
			townId:$("#townId").combobox('getValue'),
			commId:$("#commId").combobox('getValue')
		});
	}
	
	function importFact(){
		parent.$.messager.progress({
			title : '提示',
			text : '数据处理中，请稍后....'
		});
		$.ajax({
			url:"/madeCardTask/madeCardTaskAction!importFtpFileByFactory.action",
			success: function(rsp){
				parent.$.messager.progress('close');
				rsp = eval('('+rsp+')');
				if(rsp.status=='1'){
					$.messager.alert('系统消息',rsp.msg,'error');
				}else{
					parent.$.messager.show({
						title : rsp.title,
						msg : rsp.msg,
						timeout : 1000 * 2
					});
				}
				$("#bankIdimp").val('');
			}
		});
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>卡厂返回数据进行导入操作！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0"  style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft">批次号：</td>
					<td class="tableright"><input id="madeCardBatchNo" name="madeCardBatch" type="text" class="textinput" /></td>
					<td class="tableleft">任务号：</td>
					<td class="tableright"><input id="madeCardTaskNo" name="madeCardTaskNo" type="text" class="textinput" /></td>
					<td class="tableleft">任务状态：</td>
					<td class="tableright"><input id="taskState" name="taskState" type="text" class="easyui-combobox" style="width:174px;"/></td>
					<td class="tableleft">单位名称：</td>
					<td class="tableright"><input id="corpId" name="corpId"  class="easyui-combobox"  type="text"  style="width:174px;"/></td>
				</tr>
				<tr>
					<td class="tableleft">卡类型：</td>
					<td class="tableright"><input id="cardType" name="cardType" type="text"  class="easyui-combobox"  style="width:174px;"/></td>
					<td class="tableleft">任务开始日期：</td>
					<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
					<td class="tableleft">任务结束日期：</td>
					<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
					<td class="tableleft">所在城区：</td>
					<td class="tableright"><input id="regionId" name="regionId"  type="text" class="easyui-combobox"  style="width:174px;"/></td>
				</tr>
				<tr>
					<td class="tableleft">所在乡镇：</td>
					<td class="tableright"><input id="townId" name="townId" type="text" class="easyui-combobox"  style="width:174px;"/></td>
					<td class="tableleft">社区：</td>
					<td class="tableright"><input id="commId" name="commId" type="text" class="easyui-combobox" style="width:174px;"/></td>
					<td class="tableright" colspan="4" >
						<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
				   		<shiro:hasPermission name="doCardImpSave">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import"  plain="false" onclick="importFact();">制卡导入</a>
				    	</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="任务信息"></table>
	</div>
</body>
</html>