<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %> 
<script type="text/javascript"> 
    var $dg;
    var $grid;
    
	$(function() {
		$("#synGroupIdTip").tooltip({
			position:"left",    
			content:"<span style='color:#B94A48'>是否按天统计</span>" 
		});
		$("#statByDay").switchbutton({
			width:"50px",
			value:false,
            checked:false,
            onText:"是",
            offText:"否",
            onChange:function(checked){
            	if(checked){
            		$("#dg").datagrid("showColumn", "CLR_DATE");
            	} else {
            		$("#dg").datagrid("hideColumn", "CLR_DATE");
            	}
            	query();
            }
		});
		
		$.autoComplete({
			id:"coOrgId",
			value:"co_Org_Name",
			text:"co_Org_Id",
			table:"base_co_org",
			where:"co_state = '0' ",
			keyColumn:"co_Org_Id",
			minLength:1
		},"coOrgName");
		
		$.autoComplete({
			id:"coOrgName",
			value:"co_Org_Id",
			text:"co_Org_Name",
			table:"base_co_org",
			where:"co_state = '0' ",
			keyColumn:"co_Org_Name",
			minLength:1
		},"coOrgId");
		
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
		$grid = $dg.datagrid({
			url : "sysReportQuery/sysReportQueryAction!queryCoOrgRechargeCWMsg.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			pageList : [100, 200, 500, 1000, 2000],
			singleSelect:false,
			autoRowHeight:true,
			showFooter:true,
			fitColumns:true,
			view:myview,
			frozenColumns:[
				[
				 	{field:'SEQ',rowspan:4,title:'',checkbox:true},
				 	{field:'CO_ORG_ID',title:'合作机构编号',rowspan:4,align:'center',width:'120px'},
					{field:'CO_ORG_NAME',title:'合作机构名称',rowspan:4,align:'center',width:'180px'},
					{field:'CARD_TYPE',title:'卡类型',rowspan:4,align:'center',width:'80px'},
					{field:'CLR_DATE',title:'清分日期', hidden:true, rowspan:4, align:'center',width:'80px'}
				],[],[],[]
			],
			columns:[
				[
					{title:'市民卡账户',colspan:6,align:'center'},
					{title:'市民卡钱包',colspan:6,align:'center'},
					{title:'未登账户',colspan:6,align:'center'},
					{title:'总计',colspan:2,align:'center'},
					//{title:'总计',colspan:2,align:'center'},
				],
				[
					{title:'充值',colspan:2,align:'center'},
					{title:'充值撤销',colspan:2,align:'center'},
					{title:'小计',colspan:2,align:'center'},
					{title:'充值',colspan:2,align:'center'},
					{title:'充值撤销',colspan:2,align:'center'},
					{title:'小计',colspan:2,align:'center'},
					{title:'充值',colspan:2,align:'center'},
					{title:'充值撤销',colspan:2,align:'center'},
					{title:'小计',colspan:2,align:'center'},
					{field:'YDZ_NUM',title:'笔数',align:'center', rowspan:2, width:'80px'},
					{field:'YDZ_AMT',title:'金额',align:'center', rowspan:2, width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}},
					
				],
				[
				 	// 已对账 - 联机
					{field:'LJ_YDZ_CZ_NUM',title:'笔数',align:'center',width:'80px'},
					{field:'LJ_YDZ_CZ_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}},
					{field:'LJ_YDZ_CZCX_NUM',title:'笔数',align:'center',width:'80px'},
					{field:'LJ_YDZ_CZCX_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}},
					{field:'LJ_YDZ_CZ_TOT_NUM',title:'笔数',align:'center',width:'80px',formatter:function(value,row,index){
						return Number(row.LJ_YDZ_CZ_NUM) - Number(row.LJ_YDZ_CZCX_NUM);
					}},
					{field:'LJ_YDZ_CZ_TOT_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						var amt = parseFloat(row.LJ_YDZ_CZ_AMT) + parseFloat(row.LJ_YDZ_CZCX_AMT);
						return $.foramtMoney(Number(amt).div100());
					}},
					// 已对账 - 钱包
					{field:'QB_YDZ_CZ_NUM',title:'笔数',align:'center', width:'80px'},
					{field:'QB_YDZ_CZ_AMT',title:'金额',align:'center', width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}}, 
					{field:'QB_YDZ_CZCX_NUM',title:'笔数',align:'center', width:'80px'},
					{field:'QB_YDZ_CZCX_AMT',title:'金额',align:'center', width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}}, 
					{field:'QB_YDZ_CZ_TOT_NUM',title:'笔数',align:'center',width:'80px',formatter:function(value,row,index){
						return row.QB_YDZ_CZ_NUM - row.QB_YDZ_CZCX_NUM;
					}},
					{field:'QB_YDZ_CZ_TOT_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						var amt = parseFloat(row.QB_YDZ_CZ_AMT) + parseFloat(row.QB_YDZ_CZCX_AMT);
						return $.foramtMoney(Number(amt).div100());
					}},
					// 已对账 - 未登
					{field:'UR_YDZ_CZ_NUM',title:'笔数',align:'center', width:'80px'},
					{field:'UR_YDZ_CZ_AMT',title:'金额',align:'center', width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}}, 
					{field:'UR_YDZ_CZCX_NUM',title:'笔数',align:'center', width:'80px'},
					{field:'UR_YDZ_CZCX_AMT',title:'金额',align:'center', width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}}, 
					{field:'UR_YDZ_CZ_TOT_NUM',title:'笔数',align:'center',width:'80px',formatter:function(value,row,index){
						return row.UR_YDZ_CZ_NUM - row.UR_YDZ_CZCX_NUM;
					}},
					{field:'UR_YDZ_CZ_TOT_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						var amt = parseFloat(row.UR_YDZ_CZ_AMT) + parseFloat(row.UR_YDZ_CZCX_AMT);
						return $.foramtMoney(Number(amt).div100());
					}},
					
					
					{field:'YDZ_NUM',title:'笔数',align:'center',width:'80px'},
					{field:'YDZ_AMT',title:'金额',align:'center',width:'80px',formatter:function(value,row,index){
						if(value == "0"){
							return "0.00";
						}else{
							return $.foramtMoney(Number(value).div100());
						}
					}}
				]
			],
			toolbar:'#tb',
			rowStyler:function(index, row){
				if(row.isFooter){
					return "font-weight:bold";
				}
			},
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
				$grid.datagrid("autoMergeCells",["CO_ORG_ID","CO_ORG_NAME"]);
            	if(data.status != 0) {
            		$.messager.alert('系统消息',data.errMsg,'error');
            	} else {
            		$dg.datagrid("autoMergeCells",['ACPT_ID']);
            	}
            	updateFooter();
            }
		});
		
	});
	
	function updateFooter(){
		var selections = $("#dg").datagrid("getSelections");
		
		// 已对账
		// 联机
		var LJ_YDZ_CZ_NUM = 0;
		var LJ_YDZ_CZ_AMT = 0;
		var LJ_YDZ_CZCX_NUM = 0;
		var LJ_YDZ_CZCX_AMT = 0;
		// 钱包
		var QB_YDZ_CZ_NUM = 0;
		var QB_YDZ_CZ_AMT = 0;
		var QB_YDZ_CZCX_NUM = 0;
		var QB_YDZ_CZCX_AMT = 0;
		// 未登
		var UR_YDZ_CZ_NUM = 0;
		var UR_YDZ_CZ_AMT = 0;
		var UR_YDZ_CZCX_NUM = 0;
		var UR_YDZ_CZCX_AMT = 0;
		// 小计
		var YDZ_NUM = 0;
		var YDZ_AMT = 0;
		
		// 总计
		var TOT_NUM = 0;
		var TOT_AMT = 0;
		
		var num = 0;
		for(var i in selections){
			num++;
			
			var row = selections[i];
			
			LJ_YDZ_CZ_NUM += isNaN(Number(row.LJ_YDZ_CZ_NUM))?0:Number(row.LJ_YDZ_CZ_NUM);
			LJ_YDZ_CZ_AMT += isNaN(Number(row.LJ_YDZ_CZ_AMT))?0:Number(row.LJ_YDZ_CZ_AMT);
			LJ_YDZ_CZCX_NUM += isNaN(Number(row.LJ_YDZ_CZCX_NUM))?0:Number(row.LJ_YDZ_CZCX_NUM);
			LJ_YDZ_CZCX_AMT += isNaN(Number(row.LJ_YDZ_CZCX_AMT))?0:Number(row.LJ_YDZ_CZCX_AMT);
			//
			QB_YDZ_CZ_NUM += isNaN(Number(row.QB_YDZ_CZ_NUM))?0:Number(row.QB_YDZ_CZ_NUM);
			QB_YDZ_CZ_AMT += isNaN(Number(row.QB_YDZ_CZ_AMT))?0:Number(row.QB_YDZ_CZ_AMT);
			QB_YDZ_CZCX_NUM += isNaN(Number(row.QB_YDZ_CZCX_NUM))?0:Number(row.QB_YDZ_CZCX_NUM);
			QB_YDZ_CZCX_AMT += isNaN(Number(row.QB_YDZ_CZCX_AMT))?0:Number(row.QB_YDZ_CZCX_AMT);
			//
			UR_YDZ_CZ_NUM += isNaN(Number(row.UR_YDZ_CZ_NUM))?0:Number(row.UR_YDZ_CZ_NUM);
			UR_YDZ_CZ_AMT += isNaN(Number(row.UR_YDZ_CZ_AMT))?0:Number(row.UR_YDZ_CZ_AMT);
			UR_YDZ_CZCX_NUM += isNaN(Number(row.UR_YDZ_CZCX_NUM))?0:Number(row.UR_YDZ_CZCX_NUM);
			UR_YDZ_CZCX_AMT += isNaN(Number(row.UR_YDZ_CZCX_AMT))?0:Number(row.UR_YDZ_CZCX_AMT);
			//
			YDZ_NUM += isNaN(Number(row.YDZ_NUM))?0:Number(row.YDZ_NUM);
			YDZ_AMT += isNaN(Number(row.YDZ_AMT))?0:Number(row.YDZ_AMT);

			//
			//TOT_NUM += isNaN(Number(row.TOT_NUM))?0:Number(row.TOT_NUM);
			//TOT_AMT += isNaN(Number(row.TOT_AMT))?0:Number(row.TOT_AMT);
		}
		
		$("#dg").datagrid("reloadFooter", [{
			isFooter : true,
			CO_ORG_ID : "统计：",
			CO_ORG_NAME : "共 " + num + " 笔",
			//
			LJ_YDZ_CZ_NUM : LJ_YDZ_CZ_NUM,
			LJ_YDZ_CZ_AMT : LJ_YDZ_CZ_AMT,
			LJ_YDZ_CZCX_NUM : LJ_YDZ_CZCX_NUM,
			LJ_YDZ_CZCX_AMT : LJ_YDZ_CZCX_AMT,
			//
			QB_YDZ_CZ_NUM : QB_YDZ_CZ_NUM,
			QB_YDZ_CZ_AMT : QB_YDZ_CZ_AMT,
			QB_YDZ_CZCX_NUM : QB_YDZ_CZCX_NUM,
			QB_YDZ_CZCX_AMT : QB_YDZ_CZCX_AMT,
			//
			UR_YDZ_CZ_NUM : UR_YDZ_CZ_NUM,
			UR_YDZ_CZ_AMT : UR_YDZ_CZ_AMT,
			UR_YDZ_CZCX_NUM : UR_YDZ_CZCX_NUM,
			UR_YDZ_CZCX_AMT : UR_YDZ_CZCX_AMT,
			//
			YDZ_NUM : YDZ_NUM,
			YDZ_AMT : YDZ_AMT
			
			//
			//TOT_NUM : TOT_NUM,
			//TOT_AMT : TOT_AMT
		}]);
	}
	
	function query(){
		var params = getformdata("rechargeMsgFrom");
		params["queryType"] = "0";
		params["statByDay"] = $("#statByDay").prop("checked");
		$dg.datagrid('load',params);
	}
	//导出结算明细
	function execelRechargeRep(){
		var params = getformdata("rechargeMsgFrom");
		params["queryType"] = "0";
		params["statByDay"] = $("#statByDay").prop("checked");
		var paramStr = "";
		for(var i in params){
			paramStr += "&" + i + "=" + params[i];
		}
		
		var selections = $dg.datagrid("getSelections");
		var coOrgIds = "";
		if(selections && selections.length > 0){
			for(var i in selections){
				coOrgIds += selections[i].CO_ORG_ID + ",";
			}
		}
		$('#downloadcsv').attr('src','sysReportQuery/sysReportQueryAction!exportCoOrgRechargeCWMsg.action?rows=2000&coOrgIds=' + coOrgIds.substring(0, coOrgIds.length - 1) + paramStr);
	}
	
	function updateStat(){
		$.messager.progress({text:"数据处理中，请稍候..."});
		$.post("clrDeal/clrDealAction!updateCoOrgStat.action", function(data){
			$.messager.progress("close");
			if(data.status == 1){
				jAlert(data.msg);
			} else {
				query();
			}
		}, "json");
		
	}
</script>
<n:initpage title="充值情况统计</strong><span style='color:red;font-weight:700'>注意：</span>是按照网点级别进行的统计！</span>">
  	<n:center>
  		<div id="tb" style="padding:2px 0">
  			<form id="rechargeMsgFrom">
				<table cellpadding="0" cellspacing="0" width="100%" class="tablegrid">
					<tr>
						<td class="tableleft">合作机构编号：</td>
						<td class="tableright"><input id="coOrgId" type="text" class="textinput" name="coOrgId"/></td>
						<td class="tableleft">合作机构名称：</td>
						<td class="tableright"><input id="coOrgName" type="text" class="textinput" name="coOrgName"/></td>
						<td class="tableleft">清分起始日期：</td>
						<td class="tableright"><input  id="startDate" type="text" name="startDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">清分结束日期：</td>
						<td class="tableright"><input id="endDate" type="text"  name="endDate" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						</td>
					</tr>
					<tr>
						<td class="tableright" colspan="8" style="padding-left: 10px">
							<span id="synGroupIdTip">
								<input id="statByDay" name="statByDay" type="checkbox">
							</span>
							&nbsp;&nbsp;
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel"  plain="false" onclick="execelRechargeRep();">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id ="dg" title="合作机构充值情况统计(财务)"></table>
	  	<iframe id="downloadcsv" style="display:none"></iframe>
  	</n:center>
</n:initpage>
