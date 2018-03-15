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
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		//
		var countNum = 0;
		var zrjyAmt = 0;
		var jrsrNum = 0;
		var jrsrAmt = 0;
		var jrzcNum = 0;
		var jrzcAmt = 0;
		var jrjyAmt = 0;
		var frozenAmt = 0;
		
		$(function() {
			createSys_Org({id:"orgId"},{id:"branchId"},{id:"operatorId"});
			//createSysOrg("orgId","branchId","operatorId");
			//createSysBranch("branchId","operatorId",{checkbox:true,panelHeight:'auto'},{hasDownArrow:true});
			
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
			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"cashManage/cashManageAction!toQueryCashBox.action",
				fit:true,
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				autoRowHeight:true,
				showFooter: true,
				fitColumns:true,
				scrollbarSize:0,
				view:myview,
				rowStyler:function(index, row){
					if(row.isFooter){
						return "font-weight:bold";
					}
				},
				columns : [[
							{field : '', checkbox:true},
							{field : 'brch_id',title : '网点编号',sortable:true,width:parseInt($(this).width()*0.08)},
							{field : 'full_name',title : '网点名称',sortable:true,width:parseInt($(this).width()*0.15)},
							{field : 'user_id',title : '柜员编号',sortable:true,width:parseInt($(this).width()*0.077)},
							{field : 'name',title : '柜员名称',sortable:true,width:parseInt($(this).width()*0.1)},
							{field : 'coin_kind',title : '货币种类',sortable:true,width:parseInt($(this).width()*0.08)},
							{field : 'yd_blc',title : '昨日结余',sortable:true,width:parseInt($(this).width()*0.08), formatter:function(v){
								return $.foramtMoney(Number(v).div100());
							}},
							{field : 'td_in_num',title : '今日收入笔数',sortable:true,width:parseInt($(this).width()*0.08)},
							{field : 'td_in_amt',title : '今日收入金额',sortable:true,width:parseInt($(this).width()*0.08), formatter:function(v){
								return $.foramtMoney(Number(v).div100());
							}},
							{field : 'td_out_num',title : '今日支出笔数',sortable:true,width:parseInt($(this).width()*0.08)},
							{field : 'td_out_amt',title : '今日支出金额',sortable:true,width:parseInt($(this).width()*0.08), formatter:function(v){
								return $.foramtMoney(Number(v).div100());
							}},
							{field : 'td_blc',title : '今日结余',fit:true,sortable:true,width:parseInt($(this).width()*0.08), formatter:function(v){
								return $.foramtMoney(Number(v).div100());
							}},
							{field : 'frz_bal',title : '冻结金额',fit:true,sortable:true,width:parseInt($(this).width()*0.08), formatter:function(v){
								return $.foramtMoney(Number(v).div100());
							}}
				  ]],
				  toolbar:'#tb',
	              onLoadSuccess:function(data){
	            	  if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
	            	  initCount();
	            	  updateFooter();
	              },
	              onSelect:function(index, row){
	            	  calRow(true, row);
	            	  updateFooter();
	              },
	              onUnselect:function(index, row){
	            	  calRow(false, row);
	            	  updateFooter();
	              },
	              onSelectAll:function(rows){
	            	  initCount();
	            	  for(var i in rows){
	            		  calRow(true, rows[i]);
	            	  }
		              updateFooter();
	              },
	              onUnselectAll:function(rows){
	            	  initCount();
	            	  updateFooter();
	              }
			});
		});
		
		function initCount(){
			countNum = 0;
			zrjyAmt = 0;
			jrsrNum = 0;
			jrsrAmt = 0;
			jrzcNum = 0;
			jrzcAmt = 0;
			jrjyAmt = 0;
			frozenAmt = 0;
		}
		
		function calRow(add, row){
			if(add){
				countNum++;
	      	  	zrjyAmt += Number(row.yd_blc);
	      	  	jrsrNum += Number(row.td_in_num);
	      	  	jrsrAmt += Number(row.td_in_amt);
	      	  	jrzcNum += Number(row.td_out_num);
	      	  	jrzcAmt += Number(row.td_out_amt);
	      	  	jrjyAmt += Number(row.td_blc);
	      	  	frozenAmt += Number(row.frz_bal);
			} else {
				countNum--;
	      	  	zrjyAmt -= Number(row.yd_blc);
	      	  	jrsrNum -= Number(row.td_in_num);
	      	  	jrsrAmt -= Number(row.td_in_amt);
	      	  	jrzcNum -= Number(row.td_out_num);
	      	  	jrzcAmt -= Number(row.td_out_amt);
	      	  	jrjyAmt -= Number(row.td_blc);
	      	  	frozenAmt -= Number(row.frz_bal);
			}
		}
		
		function updateFooter(){
			$dg.datagrid("reloadFooter", [{
				isFooter:true,
				brch_id:"统计：",
				full_name:"共 " + countNum + " 条记录",
				yd_blc:zrjyAmt,
				td_in_num:jrsrNum,
				td_in_amt:jrsrAmt,
				td_out_num:jrzcNum,
				td_out_amt:jrzcAmt,
				td_blc:jrjyAmt,
				frz_bal:frozenAmt
			}]);
		}
		
		function query(){
			if(!$("#orgId").combotree('getValue')){
				jAlert("所属机构不能为空", "warning");
				return;
			}
			
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				branchId:$("#branchId").combotree('getValue'), 
				operatorId:$("#operatorId").combobox('getValue'),
				isZero:$("#isZero").combobox('getValue')
			});
		}
	</script>
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>柜员尾箱信息</strong></span>进行查询!</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0">
				<tr>
					<td class="tableleft">所属机构：</td>
					<td class="tableright"><input id="orgId" type="text" class="textinput" name="orgId"  style="width:174px;"/></td>
					<td class="tableleft">所属网点：</td>
					<td class="tableright"><input id="branchId" type="text" class="textinput" name="branchId"  style="width:174px;"/></td>
					<td class="tableleft">柜员：</td>
					<td class="tableright"><input id="operatorId" type="text" class="textinput" name="operatorId"  style="width:174px;"/></td>
					<td class="tableleft">是否为0：</td>
					<td class="tableright"><input name="isZero"  class="easyui-combobox" id="isZero"  value="" type="text" data-options="panelHeight:'auto',editable:false,valueField:'label',textField:'value',data:[{label:'',value:'请选择'},{label:'0',value:'是'},{label:'1',value:'否'}]"/></td>
					<td class="tableright">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="柜员尾箱信息"></table>
	</div>
</body>
</html>