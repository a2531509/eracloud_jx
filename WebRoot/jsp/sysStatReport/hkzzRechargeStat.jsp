<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %> 
<script type="text/javascript"> 
    var $dg;
    var $grid;
	$(function() {
		$("#synGroupIdTip").tooltip({
			position:"left",    
			content:"<span style='color:#B94A48'>是否级联下级网点</span>" 
		});
		$("#cascadeBrch").switchbutton({
			width:"50px",
			value:"0",
            checked:false,
            onText:"是",
            offText:"否"
		});
		
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
		createSysBranch("brchId");
		$dg = $("#dg");
		$grid = $dg.datagrid({
			url : "statistical/statisticalAnalysisAction!hkzzRechargeStat.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			fitColumns:true,
			pageList : [100, 200, 500, 1000, 2000],
			singleSelect:false,
			autoRowHeight:true,
			showFooter:true,
			view:myview,
			columns:[
				[
				 	{field:'',title:'',checkbox:true},
					{field:'ACPT_ID',title:'网点编号',align:'center',width:parseInt($(this).width()*0.1)},
					{field:'ACPT_NAME',title:'网点名称',align:'center',width:parseInt($(this).width()*0.1)},
					{field:'CARD_TYPE',title:'卡类型',align:'center',width:parseInt($(this).width()*0.1)},
					{field:'TOT_NUM',title:'笔数',align:'center',width:parseInt($(this).width()*0.1)},
					{field:'TOT_AMT',title:'金额',align:'center',width:parseInt($(this).width()*0.1),formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}}
	      		]
			],
			toolbar:'#tb',
			rowStyler:function(index, row){
				if(row.isFooter){
					return "font-weight:bold";
				}
			},
			onLoadSuccess:function(data){
            	if(data.status != 0){
            		$.messager.alert('系统消息',data.errMsg,'error');
            	}
            	updateFooter();
            },
            onSelect:function(){
            	updateFooter();
            },
            onUnselect:function(){
            	updateFooter();
            },
            onSelectAll:function(){
            	updateFooter();
            },
            onUnselectAll:function(){
            	updateFooter();
            },
            onBeforeLoad:function(params){
            	if(!params.query){
            		return false;
            	} else if(!params.beginTime || !params.endTime){
            		jAlert("起始日期和结束日期不能为空！", "warning");
            		return false;
            	}
            }
		});
		
	});
	
	function updateFooter(){
		var TOTAL_NUM = 0;
		var TOTAL_AMT = 0;
		
		var selections = $dg.datagrid("getSelections");
		if(selections && selections.length > 0){
			for(var i in selections){
				var r = selections[i];
				TOTAL_NUM += Number(r.TOT_NUM);
				TOTAL_AMT += Number(r.TOT_AMT);
			}
		}
		
		$dg.datagrid("reloadFooter", [{
			isFooter : true,
			ACPT_ID : '本页信息统计：',
			TOT_NUM : TOTAL_NUM,
			TOT_AMT : TOTAL_AMT
		}]);
	}
	
	function query(){
		var params = getformdata("rechargeMsgFrom");
		params["query"] = true;
		params["cascadeBrch"] = $("#cascadeBrch").prop("checked");
		$dg.datagrid('load',params);
	}
	//导出结算明细
	function execelRechargeRep(){
		var selections = $grid.datagrid("getSelections");
		var dealNos = "";
		if(selections && selections.length > 0){
			for(var i in selections){
				dealNos += selections[i].ACPT_ID + ",";
			}
		}
		$('#downloadcsv').attr('src','statistical/statisticalAnalysisAction!exportHkzzRechargeStat.action?queryType=0&rows=20000&cascadeBrch=' + $("#cascadeBrch").prop("checked") + '&branchIds=' + dealNos.substring(0, dealNos.length - 1) + '&' + $("#rechargeMsgFrom").serialize());
	}
</script>
<n:initpage title="换卡转钱包充值统计进行查询！">
  	<n:center>
  		<div id="tb" style="padding:2px 0">
  			<form id="rechargeMsgFrom">
				<table cellpadding="0" cellspacing="0" width="100%" class="tablegrid">
					<tr>
						<td class="tableleft">办理网点：</td>
						<td class="tableright">
							<input id="brchId" type="text" class="textinput" name="branchId"/>
							<span id="synGroupIdTip">
								<input id="cascadeBrch" type="checkbox">
							</span>
						</td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableright" colspan="2" style="padding-left: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel"  plain="false" onclick="execelRechargeRep();">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id ="dg" title="换卡转钱包充值统计"></table>
		<iframe id="downloadcsv" style="display:none"></iframe>
  	</n:center>
</n:initpage>
