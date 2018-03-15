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
    <title>现金尾箱</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
	//$.fn.datagrid.defaults.loadMsg = '正在处理，请稍待。。。';
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		$(function() {
			var myview = $.extend({}, $.fn.datagrid.defaults.view, {
			    renderFooter: function(target, container, frozen){
			        var opts = $.data(target, 'datagrid').options;
			        var rows = $.data(target, 'datagrid').footer || [];
			        var fields = $(target).datagrid('getColumnFields', frozen);
			        var table = ['<table class="datagrid-ftable" cellspacing="0" cellpadding="0" border="0"><tbody>'];
			         
			        for(var i=0; i<rows.length; i++){
			            var styleValue = opts.rowStyler ? opts.rowStyler.call(target, i, rows[i]) : '';
			            var style = styleValue ? 'style="' + styleValue + '"' : '';
			            table.push('<tr class="datagrid-row" datagrid-row-index="' + i + '"' + style + '>');
			            table.push(this.renderRow.call(this, target, fields, frozen, i, rows[i]));
			            table.push('</tr>');
			        }
			         
			        table.push('</tbody></table>');
			        $(container).html(table.join(''));
			    }
			});

			createSysBranch(
				{id:"branchId"},
				{id:"operatorId"}
			);
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "cashManage/cashManageAction!certainDepositIndex.action",
				fit:true,
				pagination:true,
				rownumbers:true,
				pageList:[100, 500, 1000, 2000, 5000],
				border:false,
				striped:true,
				autoRowHeight:true,
				showFooter: true,
				fitColumns:true,
				scrollbarSize:0,
				view:myview,
				rowStyler:function(index, row){
					if(row.DEAL_NO == '统计信息:'){
						return "font-weight:bold";
					}
				},
				columns : [[
				            {field : 'V_V',checkbox:true},
							{field : 'DEAL_NO',title : '流水编号',sortable:true,width:parseInt($(this).width()*0.06)},
							{field : 'DEAL_CODE_NAME',title : '业务名称',sortable:true,width:parseInt($(this).width()*0.15)},
							{field : 'BRCH_ID',title : '存款网点',sortable:true,width:parseInt($(this).width()*0.077)},
							{field : 'FULL_NAME',title : '存款网点名称',sortable:true,width:parseInt($(this).width()*0.077)},
							{field : 'USER_ID',title : '存款柜员编号',sortable:true,width:parseInt($(this).width()*0.1)},
							{field : 'NAME',title : '存款柜员名称',sortable:true,width:parseInt($(this).width()*0.1)},
							{field : 'AMT',title : '存款金额',sortable:true,width:parseInt($(this).width()*0.08), formatter:function(v){
								return $.foramtMoney(Number(v).div100());
							}},
							{field : 'BIZTIME',title : '存款时间',sortable:true,width:parseInt($(this).width()*0.12)},
							{field : 'RSV_ONE',title : '银行存款编号',sortable:true,width:parseInt($(this).width()*0.08)},
							{field : 'DEALSTATE',title : '状态',sortable:true,width:parseInt($(this).width()*0.06),formatter:function(value,row,index){
								if(value == "待确认"){
									return '<span style="color:red">' + value + '</span>';
								}else{
									return value;
								}
							}}
				          ]],
				  toolbar:'#tb',
				  onSelect:function(index,data){
		              updateFooter();
		          },
		          onUnselect:function(index,data){
		              updateFooter();
		          },
		          onSelectAll:function(rows){
		              updateFooter();
		          },
		          onUnselectAll:function(rows){
		              updateFooter();
		          },
	              onLoadSuccess:function(data){
	            	  if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
	              }
			});
		});
		
		function updateFooter(){
			var rows = $dg.datagrid("getSelections");
			var num = 0;
			var amt = 0;
			for(var i in rows){
				num++;
				amt += Math.abs(Number(rows[i].AMT));
			}
			
			$dg.datagrid("reloadFooter", [{DEAL_NO:"统计信息:", DEAL_CODE_NAME: num + "笔", AMT:amt}]);
		}
		
		function query(){
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				branchId:$("#branchId").combobox('getValue'), 
				operatorId:$("#operatorId").combobox('getValue'),
				dealState:$("#dealState").combobox('getValue'),
				beginTime:$("#beginTime").val(),
				endTime:$("#endTime").val(),
				dealNo:$("#dealNo").val()
			});
		}
		function sh(){
			var rows = $dg.datagrid("getSelections");
			if(!rows){
				jAlert("请选择网点存款信息！", "warninig");
				return;
			}
			var dealNos = "";
			for(var i in rows){
				dealNos += rows[i].DEAL_NO + ",";
			}
			
			$.messager.confirm("系统消息","您确行要确认该网点存款信息吗？",function(r){
				if(r){
					$.messager.progress({
						text : '数据处理中，请稍后....'
					});
					$.post("cashManage/cashManageAction!certainDepositConfirm.action",{dealNos:dealNos.substring(0, dealNos.length - 1)},function(data,status){
						$.messager.progress('close');
						if(status == "success"){
							var msg = "";
							if(data.failList.length > 0){
								for(var i in data.failList){
									msg += data.failList[i].msg + "<br>";
								}
							}
							
							var message = data.failList.length > 0? msg:data.msg;
							
							$.messager.alert("系统消息", message, (data.status == "0" ? "info" : "error"),function(){
								$dg.datagrid("reload");
							});
						}else{
							$.messager.alert("系统消息","网点存款确认发生错误，请重试！");
						}
					},'json');
				}
			});
		}
	</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>网点存款</strong></span>进行确认管理！</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
				<tr>
					<td class="tableleft">所属网点：</td>
					<td class="tableright"><input id="branchId" type="text" class="textinput  easyui-validatebox" name="branchId"  style="width:174px;"/></td>
					<td class="tableleft">柜员：</td>
					<td class="tableright"><input id="operatorId" type="text" class="textinput  easyui-validatebox" name="operatorId"  style="width:174px;"/></td>
					<td class="tableleft">起始日期：</td>
					<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					<td class="tableleft">结束日期：</td>
					<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
				</tr>
				<tr>
					<td class="tableleft">流水号：</td>
					<td class="tableright"><input id="dealNo" type="text"  name="dealNo" class="textinput"/></td>
					<td class="tableleft">状态：</td>
					<td class="tableright"><input name="dealState"  class="easyui-combobox" id="dealState" value="" type="text" data-options="editable:false,width:174,panelHeight:'auto',valueField:'label',textField:'value',data:[{label:'',value:'请选择'},{label:'0',value:'已确认'},{label:'9',value:'待确认'}]"/></td>
					<td colspan="4" class="tableright">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-checkInfo'" href="javascript:void(0);" class="easyui-linkbutton" onclick="sh()">存款确认</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="网点存款信息"></table>
	  </div>
</body>
</html>