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
		$(function() {
			//获取银行编号
			 $('#bankId').combobox({
                 valueField: 'bankId', 
                 textField: 'bankName',
                 //注册事件
                 onChange: function (newValue, oldValue) {
                     if (newValue != null) {
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
			//构造城区下拉框
			$("#regionId").combobox({ 
			    url:"commAction!getAllRegion.action",
			    editable:false, //不可编辑状态
			    cache: false,
			    panelHeight: 'auto',//自动高度适合
			    valueField:'region_Id',   
			    textField:'region_Name',
			    onLoadSuccess:function(){
			    	//1.加载成功后,设置默认
			    	var options = $("#regionId").combobox('getData');
			    	var len = options.length;
			    	if(len > 0){
			    		$(this).combobox('setValue',options[0].region_Id);
				    	$("#townId").combobox('reload','commAction!getAllTown.action?region_Id=' + options[0].region_Id);
			    	}
			    },
			    onSelect:function(option){
			    	$("#townId").combobox('clear');
			    	$("#townId").combobox('reload','commAction!getAllTown.action?region_Id=' + option.region_Id);
			    }
	 		}); 
			
			$("#townId").combobox({ 
			    url:"commAction!getAllTown.action",
			    editable:false, //不可编辑状态
			    cache: false,
			    panelHeight: 'auto',//自动高度适合
			    valueField:'town_Id',   
			    textField:'town_Name',
			    onLoadSuccess:function(){
			    	//1.加载成功后,设置默认
			    	var options = $("#townId").combobox('getData');
			    	var len = options.length;
			    	if(len > 0){
			    		$(this).combobox('setValue',options[0].town_Id);
				    	$("#commId").combobox('reload','commAction!getAllComm.action?town_Id=' + options[0].town_Id);
			    	}
			    },
			    onSelect:function(option){
			    	$("#commId").combobox('clear');
			    	$("#commId").combobox('reload','commAction!getAllComm.action?town_Id=' + option.town_Id);
			    }
	 		}); 
			$("#commId").combobox({ 
			    url:"commAction!getAllComm.action",
			    editable:false, //不可编辑状态
			    cache: false,
			    panelHeight: 'auto',//自动高度适合
			    valueField:'comm_Id',   
			    textField:'comm_Name',
			    onLoadSuccess:function(){
			    	var options = $(this).combobox('getData');
			    	var len = options.length;
			    	if(len > 0){
			    		$(this).combobox('setValue',options[0].comm_Id);
			    	}
			    }
	 		}); 
			//查询条件卡类型
			$("#cardType").combobox({
				width:174,
				url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CARD_TYPE",
				valueField:'codeValue',
				editable:false, //不可编辑状态
			    textField:'codeName',
			    panelHeight: 'auto',//自动高度适合
			    value:'100',
			    onSelect:function(node){
			 		$("#queryCardType").val(node.text);
			 	}
			});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "/madeCardTask/madeCardTaskAction!cardTaskQuery.action",
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
				//0未启用1正常2口头挂失3书面挂失9注销
				columns : [ [   {field:'SETTLEID',title:'id',sortable:true,checkbox:'ture'},
								{field:'TASK_ID',title:'任务编号',sortable:true,width : parseInt($(this).width() * 0.1)},
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
		
		function exportWJW(){
			var rows = $dg.datagrid('getChecked');
			var taskids="";
			if (rows.length>0) {
				for(var i=0;i<rows.length;i++){
					if(i==rows.length-1){
						taskids=taskids+rows[i].SETTLEID;
					}else{
						taskids=taskids+rows[i].SETTLEID+"|";
					}
					
				}
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				$.ajax({
					url:"/madeCardTask/madeCardTaskAction!exportFtpFileToWjw.action?taskids="+taskids,
					success: function(rsp){
						rsp = eval('('+rsp+')');
						parent.$.messager.progress('close');
						parent.$.messager.show({
							title : rsp.title,
							msg : rsp.msg,
							timeout : 1000 * 2
						});
						$("#bankSheetNo").val('');
						query();
					}
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择记录!",
					timeout : 1000 * 2
				});
			}
		}
		
		function importWJW(){
			parent.$.messager.progress({
				title : '提示',
				text : '数据处理中，请稍后....'
			});
			$.post("/madeCardTask/madeCardTaskAction!importFtpFileByWjw.action",
					   function(data){
							parent.$.messager.progress('close');
							parent.$.messager.show({
								title :data.title,
								msg :data.msg,
								timeout : 1000 * 2
							});
							query();
				        }, "json");
		}
		
		function exportBank(){
			//判断银行编号有没有被选择
			var bankId =$("#bankId").combobox('getValue');
			if(bankId==''){
				parent.$.messager.show({
					title : '消息提示',
					msg : '请选择银行信息',
					timeout : 1000 * 3
				});
				return false;
			}
			var rows = $dg.datagrid('getChecked');
			var taskids="";
			if (rows.length>0) {
				for(var i=0;i<rows.length;i++){
					if(i==rows.length-1){
						taskids=taskids+rows[i].SETTLEID;
					}else{
						taskids=taskids+rows[i].SETTLEID+"|";
					}
					
				}
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				$.ajax({
					url:"/madeCardTask/madeCardTaskAction!exportFtpFileToBank.action?bankId="+$("#bankId").combobox('getValue')+"&taskids="+taskids,
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
							query();
						}
						$("#bankId").val('');
						
					}
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择记录!",
					timeout : 1000 * 2
				});
			}
		}
		
		function importBank(){
			//判断银行编号有没有被选择
			var bankId =$("#bankIdimp").combobox('getValue');
			if(bankId==''){
				parent.$.messager.show({
					title : '消息提示',
					msg : '请选择银行信息',
					timeout : 1000 * 3
				});
				return false;
			}
			parent.$.messager.progress({
				title : '提示',
				text : '数据处理中，请稍后....'
			});
			$.ajax({
				url:"/madeCardTask/madeCardTaskAction!importFtpFileByBank.action?bankIdimp="+$("#bankIdimp").combobox('getValue'),
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
		
		function openAcc(){
			$.ajax({
				url:"/madeCardTask/madeCardTaskAction!openAcc.action",
				success: function(rsp){
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
		
		function backTask(){
			var rows = $dg.datagrid('getChecked');
			var taskids="";
			if (rows.length>0) {
				for(var i=0;i<rows.length;i++){
					if(i==rows.length-1){
						taskids=taskids+rows[i].SETTLEID;
					}else{
						taskids=taskids+rows[i].SETTLEID+"|";
					}
				}
				$.ajax({
					url:"/madeCardTask/madeCardTaskAction!backTask.action?taskids="+taskids,
					success: function(rsp){
						rsp = eval('('+rsp+')');
						if(rsp.status=='1'){
							$.messager.alert('系统消息',rsp.msg,'error');
						}else{
							parent.$.messager.show({
								title : rsp.title,
								msg : rsp.msg,
								timeout : 1000 * 2
							});
							query();
						}
						$("#bankId").val('');
						
					}
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择记录!",
					timeout : 1000 * 2
				});
			}
		}
	</script>
	<style>
		.label_left{text-align:right;padding-right:2px;height:28px;font-weight:400;}
		.label_right{text-align:left;padding-left:2px;height:28px;}
		#tb table,#tb table td{border:1px dotted rgb(149, 184, 231);}
		#tb table{border-left:none;border-right:none;}
	</style>
  </head>
  <body>
  <div class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>个性化制卡数据</strong></span>导出给卫生，也可以导入卫生返回!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" >
				<table cellpadding="0" cellspacing="0"  style="width:100%">
					<tr>
						<td align="right" class="label_left">批次号：</td>
						<td align="left" class="label_right"><input id="madeCardBatchNo" name="madeCardBatch" type="text" class="textinput" /></td>
						<td align="right" class="label_left">任务号：</td>
						<td align="left" class="label_right"><input id="madeCardTaskNo" name="madeCardTaskNo" type="text" class="textinput" /></td>
						<td align="right" class="label_left">任务状态：</td>
						<td align="left" class="label_right"><input id="taskState" name="taskState" type="text" class="easyui-combobox" style="width:174px;"/></td>
						<td align="right" class="label_left">单位名称：</td>
						<td align="left" class="label_right"><input id="corpId" name="corpId"  class="easyui-combobox"  type="text"  style="width:174px;"/></td>
					</tr>
					<tr>
						<td align="right" class="label_left">卡类型：</td>
						<td align="left" class="label_right"><input id="cardType" name="cardType" type="text"  class="easyui-combobox"  style="width:174px;"/></td>
						<td align="right" class="label_left">任务开始日期：</td>
						<td align="left" class="label_right"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td align="right" class="label_left">任务结束日期：</td>
						<td align="left" class="label_right"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td align="right" class="label_left">所在城区：</td>
						<td align="left" class="label_right"><input id="regionId" name="regionId"  type="text" class="easyui-combobox"  style="width:174px;"/></td>
					</tr>
					<tr>
						<td align="right" class="label_left">所在乡镇：</td>
						<td align="left" class="label_right"><input id="townId" name="townId" type="text" class="easyui-combobox"  style="width:174px;"/></td>
						<td align="right" class="label_left">社区：</td>
						<td align="left" class="label_right"><input id="commId" name="commId" type="text" class="easyui-combobox" style="width:174px;"/></td>
						<td align="left" class="label_right" colspan="4" >
								<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="cardOnlyTaskExpToHealth">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export"  plain="false" onclick="exportWJW();">导出卫生</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="cardOnlyTaskImpByHealth">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import"  plain="false" onclick="importWJW();">导入卫生返回</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="任务信息"></table>
	  </div>
	</div>
  </body>
</html>
